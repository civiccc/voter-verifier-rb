module Queries
  module VoterRecord
    module Preprocessors
      # Preprocess name data to make suitable for using in a Voter Record ElasticSearch query
      module Name
        module Patterns
          SUFFIX = /^\(*([IVX.]+|JR\.?|JUNIOR|SR\.?|SENIOR)\)*$/i
        end

        class << self
          # Prepare the data for use in an ElasticSearch query builder
          # @return [Hash]
          def preprocess(raw_first_name, raw_middle_name, raw_last_name)
            first, middle = split_first_when_empty_middle(raw_first_name, raw_middle_name)
            first, middle, last = extract_suffixes(first, middle, raw_last_name)

            { first: first, middle: middle, last: last }
          end

          private

          def split_first_when_empty_middle(first, middle)
            if !first.nil? && (middle.nil? || middle.empty?)
              split_first = first.split(' ')
              first, middle = split_first if split_first.length == 2
            end

            [first, middle]
          end

          def extract_suffixes(first, middle, last)
            [first, middle, last].map { |str| extract_suffix(str) }
          end

          def extract_suffix(str)
            return if str.nil?

            str.split(' ').map { |part| part.gsub(Name::Patterns::SUFFIX, '') }.join(' ')
          end
        end
      end
    end
  end
end
