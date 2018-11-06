module Queries
  module VoterRecord
    module Clauses
      # Clauses related to phone number fields
      module Phone
        def self.exact(parent_clause, value)
          parent_clause.bool do
            should { term phone: value }
            should { term vb_phone: value }
            should { term vb_phone_wireless: value }
            should { term ts_wireless_phone: value }
          end
        end
      end
    end
  end
end
