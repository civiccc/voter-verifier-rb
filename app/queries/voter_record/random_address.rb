require_relative 'clauses/address'

# TODO better approach to verification
module Queries
  module VoterRecord
    # Elasticsearch query for retrieving <limit> pseudo-random addresses in a given state
    class RandomAddress
      MAX_OFFSET = 50_000

      attr_reader :limit, :seed, :state

      def initialize(state:, seed:, limit: 10)
        @limit = limit
        @state = state
        @seed = seed.to_i
      end

      def offset_from_seed
        query = self

        DSL::Search.new do
          Queries::VoterRecord::Clauses::Address::State.exact(self, query.state)

          size query.limit
          from query.seed % MAX_OFFSET
        end
      end
    end
  end
end
