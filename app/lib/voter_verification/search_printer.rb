module VoterVerification
  # Execute a search with the given search arguments
  # and output results to stdout.
  class SearchPrinter
    def initialize(search_args:, verbose: false)
      @search_args = search_args
      @verbose = verbose
    end

    def run
      verbose { puts "Query args: #{@search_args}" }
      search = VoterVerification::Search.new(
        query_args: @search_args.except(:max_results),
        max_results: @search_args[:max_results],
        smart_search: true,
      )
      verbose { puts JSON.pretty_generate(search.query.top.to_hash) }
      results, auto_verify = search.run
      verbose { puts "Auto? #{auto_verify}" }
      non_verbose do
        puts "\tScore\tAuto?\tDocument"
        results.each_with_index.map do |res, i|
          values = %i[id last_name first_name middle_name dob zip_code city st].
            map { |k| "#{k}: #{res.public_send(k)}" }.join(', ')
          puts "#{i + 1}\t#{res.score}\t#{auto_verify}\t#{values}"
        end
      end
      verbose { results.map { |res| puts "score: #{res.score}\nhit: #{res.inspect}\n\n" } }
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
