require_relative 'base_score_function'
require 'elasticsearch/dsl'

module Queries
  # extend Elasticsearch::DSL
  module VoterRecord
    module ScoreFunctions
      # Score functions related to address fields
      module Address
        # Score functions across all address fields
        module Full
          extend BaseScoreFunction

          def self.city_state(city, state)
            city_filter = DSL::Filter.new._and do
              Clauses::Address::City.exact(self, city)
              Clauses::Address::State.exact(self, state)
            end

            state_filter = Clauses::Address::State.exact(DSL::Filter.new, state)
            [boost_factor(1, city_filter), boost_factor(1, state_filter)]
          end

          def self.street_city_and_state(street_address, city, state)
            street_address_filter = DSL::Filter.new._and do
              Clauses::Address::StreetAddress.fuzzy(self, street_address)
              Clauses::Address::City.exact(self, city)
              Clauses::Address::State.exact(self, state)
            end
            functions = city_state(city, state)
            functions << boost_factor(1, street_address_filter) unless street_address.nil?
            functions
          end
        end

        # Score functions for zip code fields
        module ZipCode
          extend BaseScoreFunction

          def self.exact(value)
            filter = Clauses::Address::ZipCode.exact(DSL::Filter.new, value)
            boost_factor(1, filter)
          end
        end

        # Score functions for lat/long location fields
        module LatLng
          extend BaseScoreFunction

          def self.within(distance, lat, lng)
            filter = Clauses::Address::LatLng.within(DSL::Filter.new, distance, lat, lng)
            boost_factor(6, filter)
          end
        end
      end
    end
  end
end
