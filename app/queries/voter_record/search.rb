module Queries
  module VoterRecord
    # Factory class to build the available Voter Record Elasticsearch query types
    # - auto: A restrictive search intended to find a single, high-confidence match (or no matches)
    # - top: A somewhat permissive search intended to find either a single, high-confidence match
    #        or multiple medium-confidence matches (or no matches)
    class Search
      MIN_SCORE_AUTO_WITH_DOB = 14.9
      MIN_SCORE_AUTO_NO_DOB = 11.9
      MIN_SCORE_TOP = 7.0

      attr_reader :alt_first_name, :alt_middle_name, :alt_last_name, :dob, :email, :first_name,
                  :middle_name, :last_name, :lat, :lng, :phone, :street_address, :city, :state,
                  :zip_code

      def initialize(size:, last_name: nil, first_name: nil, middle_name: nil,
                     alt_first_name: nil, alt_middle_name: nil, alt_last_name: nil,
                     street_address: nil, city: nil, state: nil, zip_code: nil,
                     dob: nil, email: nil, phone: nil, min_score: 1.0)
        preprocessed_address = Preprocessors::Address.preprocess(
          street_address, city, state, zip_code
        )
        preprocessed_name = Preprocessors::Name.preprocess(first_name, middle_name, last_name)
        preprocessed_alt_name = Preprocessors::Name.preprocess(
          alt_first_name, alt_middle_name, alt_last_name
        )

        @size = size

        @first_name, @middle_name, @last_name = preprocessed_name.values_at(
          :first, :middle, :last
        )
        @alt_first_name, @alt_middle_name, @alt_last_name = preprocessed_alt_name.values_at(
          :first, :middle, :last
        )

        @street_address, @city, @state, @zip_code, @lat, @lng = preprocessed_address.
          values_at(:street_address, :city, :state, :zip_code, :lat, :lng)

        @dob = dob
        @email = email
        @phone = Preprocessors::Phone.preprocess(phone)
      end

      def auto
        return unless can_auto_verify?

        query = self
        filters = DSL::Filter.new do
          bool do
            must do
              Clauses::Name::Last.exact(self, query.last_name, query.alt_last_name)
            end

            must do
              _or do
                unless query.first_name.nil?
                  Clauses::Name::First.synonym(self, query.first_name, query.alt_first_name)
                end
                unless query.middle_name.nil?
                  Clauses::Name::Middle.synonym(self, query.middle_name, query.alt_middle_name)
                end
              end
            end

            must do
              _or do
                Clauses::DOB::Year.missing_or_exact(self, query.dob.year) unless query.dob.nil?
                unless query.lat.nil? || query.lng.nil?
                  Clauses::Address::LatLng.within(self, '16km', query.lat, query.lng)
                end
              end
            end
          end
        end

        min_score = dob.nil? ? MIN_SCORE_AUTO_NO_DOB : MIN_SCORE_AUTO_WITH_DOB

        build_with_function_score(filters, min_score: min_score)
      end

      def top
        query = self

        filters = DSL::Filter.new do
          bool do
            must do
              # TODO enforce either last_name or one of email/phone
              if !query.last_name.nil?
                Clauses::Name::Last.exact(self, query.last_name, query.alt_last_name)
              else
                bool do
                  should { query { Clauses::Email.exact(self, query.email) } } unless query.email.nil?
                  should { Clauses::Phone.exact(self, query.phone) } unless query.phone.nil?
                end
              end
            end

            unless query.first_name.nil? && query.middle_name.nil?
              must do
                _or do
                  unless query.first_name.nil?
                    Clauses::Name::First.synonym(self, query.first_name, query.alt_first_name)
                  end
                  unless query.middle_name.nil?
                    Clauses::Name::Middle.synonym(self, query.middle_name, query.alt_middle_name)
                  end
                end
              end
            end

            unless query.dob.nil?
              must do
                Clauses::DOB::Year.fuzzy(self, query.dob.year)
              end
            end
          end
        end

        build_with_function_score(filters, min_score: MIN_SCORE_TOP)
      end

      # Build Elasticsearch voter records query by email or phone or both
      # If both phone and email are specified, the intersection is taken.
      def contact
        query = self
        # only one:
        if email.blank? || phone.blank?
          # if phone, do a constant_score on the match clause
          if email.blank?
            filters = [Clauses::Phone.exact(DSL::Filter.new, query.phone)]
            build_with_constant_score(filters)
          # if email, just do the match clause
          else
            DSL::Search.new { query Clauses::Email.exact(DSL::Query.new, query.email) }
          end
        # both?
        else
          # use phone number as a filter
          filters = [Clauses::Phone.exact(DSL::Filter.new, phone)]
          # use email as the filter function, build with function_score
          build_with_function_score(filters)
        end
      end

      private

      def function_scores
        functions = []

        unless @first_name.nil?
          functions << ScoreFunctions::Name::First.synonym(@first_name, @alt_first_name)
          functions << ScoreFunctions::Name::First.exact(@first_name, @alt_first_name)
        end

        functions << if @middle_name.nil?
                       ScoreFunctions::Name::Middle.is_missing
                     else
                       ScoreFunctions::Name::Middle.fuzzy(@middle_name)
                     end

        unless dob.nil?
          functions << ScoreFunctions::DOB::Year.is_missing
          functions << ScoreFunctions::DOB::Year.exact(@dob.year)
          functions << ScoreFunctions::DOB::Month.exact_or_missing_or_is_first(@dob.month)
          functions << ScoreFunctions::DOB::Day.exact_or_missing_or_is_first(@dob.day)
        end

        unless @zip_code.nil?
          functions << ScoreFunctions::Address::ZipCode.exact(@zip_code)
          unless @lat.nil? || @lng.nil? || @last_name.nil?
            functions << ScoreFunctions::Address::LatLng.within('16km', @lat, @lng)
          end
        end

        unless @city.nil? || @state.nil?
          functions << ScoreFunctions::Address::Full.street_city_and_state(
            @street_address, @city, @state
          )
        end

        functions << ScoreFunctions::Email.exact(@email) unless @email.nil?
        functions << ScoreFunctions::Phone.exact(@phone) unless @phone.nil?

        functions.flatten
      end

      def build_with_constant_score(filters)
        size = @size
        DSL::Search.new do
          query do
            constant_score do
              filter filters
            end
          end
          size size
        end
      end

      def build_with_function_score(filters, min_score: nil)
        functions = function_scores
        size = @size

        DSL::Search.new do
          query do
            function_score do
              filter filters
              functions functions
              score_mode :sum
            end
          end

          min_score min_score unless min_score.nil?
          size size
        end
      end

      def can_auto_verify?
        # last name not nil and dob/(lat,lng) not both nil and first_name/middle_name not both nil
        !@last_name.nil? &&
          (!!@dob || (!!@lat && !!@lng)) &&
          !(@first_name.nil? && @middle_name.nil?)
      end
    end
  end
end
