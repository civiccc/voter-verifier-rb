require_relative 'base_clause'

module Queries
  module VoterRecord
    module Clauses
      module Name
        # Constant names of available ElasticSearch field analyzers
        # These analyzers are defined in Pluribus, in the job that ingests the TargetSmart data and
        # builds the ElasticSearch indices. See:
        # ***REMOVED***
        module Analyzers
          # Applies a lowercase filter and an alphanumeric filter to normalize
          # - e.g. hyphenated names (Newton-John => newtonjohn)
          # - e.g. spaces in names (Mac Donald -> macdonald)
          COMPACT = 'name_compact_analyzer'.freeze
          # Applies a custom filter to add tokens for common first name synonyms
          # - e.g. "Bob" for "Robert". The synonyms are maintained in code in Pluribus.
          FIRST = 'first_name_analyzer'.freeze
        end

        # Util functions useful for all name clauses
        module BaseNameClause
          def or_alt_value(parent_clause, value, alt_value)
            if alt_value.nil?
              yield parent_clause, value
            else
              parent_clause._or do
                yield self, value
                yield self, alt_value
              end
            end
          end
        end

        # Filter clauses for first_name fields
        module First
          extend BaseNameClause

          def self.exact(parent_clause, value, alt_value)
            or_alt_value(parent_clause, value, alt_value) do |parent, val|
              parent.query { match_phrase first_name: val }
            end
          end

          def self.synonym(parent_clause, value, alt_value)
            or_alt_value(parent_clause, value, alt_value) do |parent, val|
              parent._or do
                query do
                  multi_match do
                    analyzer Analyzers::FIRST
                    type MultiMatchTypes::PHRASE
                    query val
                    fields %i[first_name middle_name]
                  end
                end
                query do
                  multi_match do
                    analyzer Analyzers::COMPACT
                    query val
                    type MultiMatchTypes::PHRASE
                    fields %i[first_name_compact middle_name_compact]
                  end
                end
              end
            end
          end
        end

        # Filter clauses for last_name fields
        module Last
          extend BaseNameClause

          def self.exact(parent_clause, value, alt_value)
            or_alt_value(parent_clause, value, alt_value) do |parent, val|
              parent._or do
                query { match last_name: val }
                query do
                  match :last_name_compact do
                    analyzer Analyzers::COMPACT
                    query val
                  end
                end
              end
            end
          end
        end

        # Filter clauses for middle_name fields
        module Middle
          extend BaseNameClause

          def self.fuzzy(parent_clause, value)
            if value.length == 1
              initial(parent_clause, value)
            else
              full(parent_clause, value)
            end
          end

          def self.synonym(parent_clause, value, alt_value)
            or_alt_value(parent_clause, value, alt_value) do |parent, val|
              parent._or do
                query do
                  multi_match do
                    analyzer Analyzers::FIRST
                    type MultiMatchTypes::PHRASE
                    query val
                    fields %i[first_name middle_name]
                  end
                end
                query do
                  multi_match do
                    analyzer Analyzers::COMPACT
                    query val
                    type MultiMatchTypes::PHRASE
                    fields %i[first_name_compact middle_name_compact]
                  end
                end
              end
            end
          end

          class << self
            private

            def initial(parent_clause, value)
              # prefix searches don't use analyzers, so we need to downcase
              parent_clause.query { prefix middle_name: value.downcase }
            end

            def full(parent_clause, value)
              parent_clause._or do
                query do
                  match_phrase :middle_name do
                    analyzer Analyzers::FIRST
                    query value
                  end
                end
                query do
                  match_phrase :middle_name_compact do
                    analyzer Analyzers::COMPACT
                    query value
                  end
                end
                query do
                  multi_match do
                    query value[0]
                    fields %i[middle_name middle_name_compact]
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
