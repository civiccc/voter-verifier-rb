require 'elasticsearch/dsl'
include Elasticsearch::DSL # rubocop:disable Style/MixinUsage

# Query builder for searching the votizen_voter index in ElasticSearch
module Queries
  module VoterRecord
    # Definitions of document filter clauses used to narrow down results
    module Clauses; end

    # Definitions of function_score functions used to adjust document match scores
    # The available types are:
    module ScoreFunctions; end

    # Factory class to build the available Voter Record Elasticsearch query types
    # - auto: A restrictive search intended to find a single, high-confidence match (or no matches)
    # - top: A somewhat permissive search intended to find either a single, high-confidence match
    #        or multiple medium-confidence matches (or no matches)
    class Query
      attr_reader :alt_first_name, :alt_middle_name, :alt_last_name, :dob, :first_name,
                  :middle_name, :lng, :last_name, :lat

      def initialize(last_name:, max_results:, first_name: nil, middle_name: nil,
                     alt_first_name: nil, alt_middle_name: nil, alt_last_name: nil,
                     street_address: nil, city: nil, state: nil, zip_code: nil,
                     dob: nil, email: nil, phone: nil)
        preprocessed_address = Preprocessors::Address.preprocess(
          street_address, city, state, zip_code
        )
        preprocessed_name = Preprocessors::Name.preprocess(first_name, middle_name, last_name)
        preprocessed_alt_name = Preprocessors::Name.preprocess(
          alt_first_name, alt_middle_name, alt_last_name
        )

        @max_results = max_results

        @first_name, @middle_name, @last_name = preprocessed_name.values_at(
        :first, :middle, :last
        )
        @alt_first_name, @alt_middle_name, @alt_last_name = preprocessed_alt_name.values_at(
        :first, :middle, :last
        )

        @street_address, @city, @state, @zip_code, @lat, @lng = preprocessed_address.
          values_at(street_address, :city, :state, :zip_code, :lat, :lng)

        @dob = dob
        @email = email
        @phone = phone
      end

      def auto
        return unless can_auto_verify?

        query = self
        filters = Search::Filter.new do
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

        build(filters)
      end

      def top
        query = self
        filters = Search::Filter.new do
          bool do
            must do
              Clauses::Name::Last.exact(self, query.last_name, query.alt_last_name)
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

        build(filters)
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

        if @zip_code.nil?
          unless @city.nil? || @state.nil?
            functions << ScoreFunctions::Address::Full.city_state(@city, @state)
            unless @street_address.nil?
              functions << ScoreFunctions::Address::Full.street_city_and_state(
                @street_address, @city, @state
              )
            end
          end
        else
          functions << ScoreFunctions::Address::ZipCode.exact(@zip_code)
          unless @lat.nil? || @lng.nil?
            functions << ScoreFunctions::Address::LatLng.within('16km', @lat, @lng)
          end
        end

        functions << ScoreFunctions::Email.exact(@email) unless @email.nil?

        functions.flatten
      end

      def build(filters)
        functions = function_scores
        max_results = @max_results
        search do
          query do
            function_score do
              filter filters
              functions functions
              score_mode :sum
            end
          end

          min_score 1.0
          size max_results
        end
      end

      def can_auto_verify?
        # dob/zip code not both nil and first_name/middle_name not both nil
        !(@dob.nil? && @zip_code.nil?) && !(@first_name.nil? && @middle_name.nil?)
      end
    end
  end
end
