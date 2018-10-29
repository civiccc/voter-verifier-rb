module VoterVerification
  # Execute a search with the given query arguments and output results to stdout.
  class SearchPrinter
    def initialize(query_args:, verbose: false)
      @query_args = query_args
      @verbose = verbose
    end

    def run
      verbose { puts "Query args: #{@query_args}" }
      search = VoterVerification::Search.new(@query_args, smart_search: true)
      verbose { puts JSON.pretty_generate(search.query.top.to_hash) }
      results = search.run
      non_verbose do
        puts "Score\tAuto?\tDocument"
        results.map do |res|
          values = %i[id last_name first_name middle_name dob zip_code city st].
            map { |k| "#{k}: #{res.public_send(k)}" }.join(', ')
          puts "#{res.score}\t#{res.auto_verify}\t#{values}"
        end
      end
      verbose { results.map { |res| puts "#{res.inspect}\n\n" } }
    end

    private

    def non_verbose(&block)
      !@verbose && instance_eval(&block)
    end

    def verbose(&block)
      @verbose && instance_eval(&block)
    end
  end
end
