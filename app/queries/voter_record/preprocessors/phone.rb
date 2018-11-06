module Queries
  module VoterRecord
    module Preprocessors
      # Preprocess phone number data to make usable in Elasticsearch Queries
      module Phone
        def self.preprocess(raw_phone_num)
          return if raw_phone_num.nil?

          stripped = raw_phone_num.delete('+')[-10..-1]
          stripped unless stripped.empty?
        end
      end
    end
  end
end
