require_relative 'base_score_function'

module Queries
  module VoterRecord
    module ScoreFunctions
      # Score functions related to name fields
      module Name
        # Score functions for first name fields
        module First
          extend BaseScoreFunction

          def self.synonym(value, alt_value)
            filter = Clauses::Name::First.synonym(DSL::Filter.new, value, alt_value)
            boost_factor(5, filter)
          end

          def self.exact(value, alt_value)
            filter = Clauses::Name::First.exact(DSL::Filter.new, value, alt_value)
            boost_factor(2, filter)
          end
        end

        # Score functions for middle name fields
        module Middle
          extend BaseScoreFunction

          def self.is_missing
            super(1, :middle_name)
          end

          def self.fuzzy(value)
            filter = Clauses::Name::Middle.fuzzy(DSL::Filter.new, value)
            boost_factor(1, filter)
          end
        end
      end
    end
  end
end
