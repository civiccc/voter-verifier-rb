module Queries
  module VoterRecord
    module Clauses
      # Query clauses for email fields
      module Email
        def self.exact(parent_clause, value)
          parent_clause.term email: value
        end
      end
    end
  end
end
