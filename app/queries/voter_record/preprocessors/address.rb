module Queries
  module VoterRecord
    module Preprocessors
      # Preprocess address data to make suitable for using in a Voter Record ElasticSearch query
      module Address
        class ConfigError < RuntimeError; end

        # Regex patterns used by the preprocessor
        module Patterns
          ZIP_PLUS_FOUR = /^(?<zip5>\d{5})(?:-(?<zip4>\d{4}))?$/
        end

        class << self
          attr_writer :geocoder

          # Prepare the data for use in an ElasticSearch query builder
          # @param raw_street_address [String]
          # @param raw_city [String]
          # @param raw_state [String]
          # @param raw_zip_code [String]
          # @return [Hash]
          def preprocess(raw_street_address, raw_city, raw_state, raw_zip_code)
            zip5 = normalize_zip_code(raw_zip_code)[:zip5]
            lat_lng = geocode_by_zip_code(zip5)

            {
              street_address: raw_street_address,
              city: raw_city,
              state: raw_state&.upcase,
              zip_code: zip5,
              lat: lat_lng[:lat],
              lng: lat_lng[:lng],
            }
          end

          private

          def geocoder
            raise ConfigError, 'No geocoder configured' if @geocoder.nil?

            @geocoder
          end

          def geocode_by_zip_code(zip)
            geocoder.geocode(zip) || {}
          end

          def normalize_zip_code(zip_code)
            Address::Patterns::ZIP_PLUS_FOUR.match(zip_code) || {}
          end
        end
      end
    end
  end
end
