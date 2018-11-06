require_relative 'base_score_function'
require 'elasticsearch/dsl'
include Elasticsearch::DSL # rubocop:disable Style/MixinUsage

module Queries
  module VoterRecord
    module ScoreFunctions
      # Score functions related to date of birth fields
      module DOB
        # Score functions for dob_year
        module Year
          extend BaseScoreFunction

          def self.is_missing
            super(1, :dob_year)
          end

          def self.exact(value)
            filter = Clauses::DOB::Year.exact(Search::Filter.new, value)
            boost_factor(5, filter)
          end
        end

        # Score functions for dob_month
        module Month
          extend BaseScoreFunction

          # VoterBase data frequently reports DOBs with month and day values they don't know as "01"
          # instead of null e.g. "1980-01-01" when in reality, all they know is the year is "1980".
          # But not always: sometimes it's null. So we include two score boosters: a higher one for
          # an exact match, and a lower one when the value is missing or equal to 1.
          def self.exact_or_missing_or_is_first(value)
            if value == 1
              [exact(value), is_missing]
            else
              [exact(value), missing_or_is_first]
            end
          end

          def self.exact(value)
            filter = Clauses::DOB::Month.exact(Search::Filter.new, value)
            boost_factor(2, filter)
          end

          def self.is_missing
            super(1, :dob_month)
          end

          def self.missing_or_is_first
            filter = Clauses::DOB::Month.missing_or_is_first(Search::Filter.new)
            boost_factor(1, filter)
          end
        end

        # Score functions for dob_day
        module Day
          extend BaseScoreFunction

          # VoterBase data frequently reports DOBs with month and day values they don't know as "01"
          # instead of null e.g. "1980-01-01" when in reality, all they know is the year is "1980".
          # But not always: sometimes it's null. So we include two score boosters: a higher one for
          # an exact match, and a lower one when the value is missing or equal to 1.
          def self.exact_or_missing_or_is_first(value)
            if value == 1
              [exact(value), is_missing]
            else
              [exact(value), missing_or_is_first]
            end
          end

          def self.exact(value)
            filter = Clauses::DOB::Day.exact(Search::Filter.new, value)
            boost_factor(2, filter)
          end

          def self.is_missing
            super(1, :dob_day)
          end

          def self.missing_or_is_first
            filter = Clauses::DOB::Day.missing_or_is_first(Search::Filter.new)
            boost_factor(1, filter)
          end
        end
      end
    end
  end
end
