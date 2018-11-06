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
          values = %i[id last_name first_name middle_name email dob].
            map { |k| "#{k}: #{res.public_send(k)}" }.join(', ')
          address = %i[address st city zip_code].
            map { |k| "#{k}: #{res.public_send(k)}" }.join(', ')
          ts_address = %i[ts_address ts_st ts_city ts_zip_code].
            map { |k| "#{k}: #{res.public_send(k)}" }.join(', ')

          puts "#{i + 1}\t#{res.score}\t#{auto_verify}\t#{values}"
          puts "\t\t\t#{address}"
          puts "\t\t\t#{ts_address}"
        end.empty? && 1.times.each { puts "\tNo results" }
      end
      verbose do
        results.each do |res|
          puts "score: #{res.score}"
          puts "hit: #{res.inspect}"
        end
      end
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
