require_relative 'base_score_function'
require 'elasticsearch/dsl'
include Elasticsearch::DSL # rubocop:disable Style/MixinUsage

module Queries
  module VoterRecord
    module ScoreFunctions
      # Score functions related to address fields
      module Address
        # Score functions across all address fields
        module Full
          extend BaseScoreFunction

          def self.city_state(city, state)
            filter = Search::Filter.new._and do
              Clauses::Address::City.exact(self, city)
              Clauses::Address::State.exact(self, state)
            end
            boost_factor(2, filter)
          end

          def self.street_city_and_state(street_address, city, state)
            filter = Search::Filter.new._and do
              Clauses::Address::StreetAddress.fuzzy(self, street_address)
              Clauses::Address::City.exact(self, city)
              Clauses::Address::State.exact(self, state)
            end
            boost_factor(3, filter)
          end
        end

        # Score functions for zip code fields
        module ZipCode
          extend BaseScoreFunction

          def self.exact(value)
            filter = Clauses::Address::ZipCode.exact(Search::Filter.new, value)
            boost_factor(1, filter)
          end
        end

        # Score functions for lat/long location fields
        module LatLng
          extend BaseScoreFunction

          def self.within(distance, lat, lng)
            filter = Clauses::Address::LatLng.within(Search::Filter.new, distance, lat, lng)
            boost_factor(6, filter)
          end
        end
      end
    end
  end
end
