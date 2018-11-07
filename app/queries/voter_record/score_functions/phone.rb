require_relative 'base_score_function'

module Queries
  module VoterRecord
    module ScoreFunctions
      # Score functions related to phone number fields
      module Phone
        extend BaseScoreFunction

        def self.exact(value)
          filter = Clauses::Phone.exact(Queries::Filter.new, value)
          boost_factor(8, filter)
        end
      end
    end
  end
end
