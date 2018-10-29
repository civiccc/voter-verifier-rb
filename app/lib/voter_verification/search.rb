# Module containing classes ans utils related to VoterVerification as
# a Brigade concept
module VoterVerification
  # Perform a Voter Verification Search with the given query arguments
  class Search
    attr_reader :query

    def initialize(query_args, opts = {})
      @query = Queries::VoterRecord::Query.new(query_args)
      @smart_search = opts[:smart_search]
    end

    def run
      return run_smart_search if @smart_search

      VoterRecord.search(query.top)
    end

    private

    def run_smart_search
      auto_matches = VoterRecord.search(query.auto, auto_verify_results: true)
      if auto_matches.empty?
        VoterRecord.search(query.top)
      else
        auto_matches
      end
    end
  end
end
