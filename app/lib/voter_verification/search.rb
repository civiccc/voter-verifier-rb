# Module containing classes ans utils related to VoterVerification as
# a Brigade concept
module VoterVerification
  # Perform a Voter Verification Search with the given query arguments
  class Search
    attr_reader :query

    AUTO_VERIFY_EQUIVALENCE_WIDTH = 3
    DEFAULT_EQUIVALENCE_WIDTH = 2

    def initialize(query_args:, max_results:, smart_search: false)
      @max_results = max_results
      # Fetch one more than the desired max from Elasticsearch so that when
      # we group into equivalence classes, we know whether the last group
      # is small enough to fit under the max results.
      @query = Queries::VoterRecord::Query.new(
        query_args.merge(size: @max_results + 1),
      )
      @smart_search = smart_search
    end

    def run
      return smart_search if @smart_search

      [top_search, false]
    end

    private

    def group_by_equivalence(hits, equivalence_width)
      return [] if hits.empty?

      curr_group = []

      groups = []
      curr_group_anchor_score = hits[0].score
      hits.each do |hit|
        if (hit.score - curr_group_anchor_score).abs < equivalence_width
          curr_group << hit
        else
          groups << curr_group
          curr_group = [hit]
          curr_group_anchor_score = hit.score
        end
      end

      # get the jagged edge
      groups << curr_group unless curr_group.empty?

      groups
    end

    def smart_search
      auto_hits = auto_search
      if auto_hits.empty?
        [top_search, false]
      else
        [auto_hits, true]
      end
    end

    def auto_search
      flatten_groups(
        group_by_equivalence(VoterRecord.search(query.auto), AUTO_VERIFY_EQUIVALENCE_WIDTH), 1
      )
    end

    def top_search
      flatten_groups(
        group_by_equivalence(VoterRecord.search(query.top), DEFAULT_EQUIVALENCE_WIDTH), @max_results
      )
    end

    def flatten_groups(groups, max_results)
      flattened = []
      remaining = max_results
      groups.each do |group|
        group_size = group.length

        break unless group_size <= remaining

        flattened.concat(group)
        remaining -= group_size
      end
      flattened
    end
  end
end
