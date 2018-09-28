require 'elasticsearch/dsl'
include Elasticsearch::DSL # rubocop:disable Style/MixinUsage

module Queries
  module VoterRecord
    module ScoreFunctions
      # Common utilities useful for all score functions
      module BaseScoreFunction
        def boost_factor(factor, filter)
          { boost_factor: factor, filter: filter.to_hash }
        end

        def is_missing(factor, field)
          filter = Search::Filter.new.missing field: field
          boost_factor(factor, filter)
        end
      end
    end
  end
end
