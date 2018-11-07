require_relative 'base_score_function'

module Queries
  module VoterRecord
    module ScoreFunctions
      # Score functions related to email fields
      module Email
        extend BaseScoreFunction

        def self.exact(value)
          filter = Clauses::Email.exact(Queries::Filter.new, value)
          boost_factor(8, filter)
        end
      end
    end
  end
end
