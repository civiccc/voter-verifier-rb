module Queries
  module VoterRecord
    module Clauses
      # Query clauses related to date of birth fields
      module DOB
        # Query clauses related to dob_day
        module Day
          def self.exact(parent_clause, value)
            parent_clause.term dob_day: value
          end

          def self.missing_or_is_first(parent_clause)
            parent_clause._or do
              term dob_day: 1
              missing field: :dob_day
            end
          end
        end

        # Query clauses related to dob_month
        module Month
          def self.exact(parent_clause, value)
            parent_clause.term dob_month: value
          end

          def self.missing_or_is_first(parent_clause)
            parent_clause._or do
              missing field: :dob_month
              _and do
                term dob_month: 1
                term dob_day: 1
              end
            end
          end
        end

        # Query clauses related to dob_year
        module Year
          def self.missing_or_exact(parent_clause, value)
            parent_clause._or do
              missing field: :dob_year
              term dob_year: value
            end
          end

          def self.exact(parent_clause, value)
            parent_clause.term dob_year: value
          end

          def self.missing(parent_clause)
            parent_clause.missing field: :dob_year
          end

          def self.fuzzy(parent_clause, year)
            parent_clause._or do
              missing field: :dob_year

              range :dob_year do
                gte year - 1
                lte year + 1
              end
            end
          end
        end
      end
    end
  end
end
