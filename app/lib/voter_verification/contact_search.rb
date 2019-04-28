# Module that supports requests that search exclusively by contact method
module VoterVerification
  
  class ContactSearch
    attr_reader :query

    def initialize(query_args:, max_results:)
      @max_results = max_results
      @query = Queries::VoterRecord::Query.new(query_args.merge(size: @max_results))
    end

    def run
      VoterRecord.search(query.contact)
    end
  end
end
