require_relative 'base_clause'

module Queries
  module VoterRecord
    module Clauses
      module Address
        # Query clauses related to city fields
        module City
          def self.exact(parent_clause, value)
            parent_clause.query do
              multi_match do
                fields %i[city ts_city]
                query value
                type MultiMatchTypes::PHRASE
              end
            end
          end
        end

        # Query clauses related to lat/lng fields
        module LatLng
          def self.within(parent_clause, distance, lat, lng)
            parent_clause._or do
              geo_distance distance: distance, lat_lng_location: "#{lat},#{lng}"
              geo_distance distance: distance, ts_lat_lng_location: "#{lat},#{lng}"
            end
          end
        end

        # Query clauses related to state fields
        module State
          def self.exact(parent_clause, value)
            parent_clause.query do
              multi_match do
                fields %i[st ts_st]
                query value
              end
            end
          end
        end

        # Query clauses related to street address fields
        module StreetAddress
          def self.fuzzy(parent_clause, value)
            parent_clause.query do
              multi_match do
                fields %i[address ts_address]
                query value
                slop 2
                type MultiMatchTypes::PHRASE
              end
            end
          end
        end

        # Query clauses related to zip_code fields
        module ZipCode
          def self.exact(parent_clause, value)
            parent_clause.query do
              multi_match do
                fields %i[zip_code ts_zip_code]
                query value
              end
            end
          end
        end
      end
    end
  end
end
