# Module that supports requests that search exclusively by contact method
module VoterVerification
  # Search elasticsearch voter records by email or phone or both
  # If both phone and email are specified, the intersection is taken.
  module ContactSearch
    include Elasticsearch::DSL

    class << self
      def lookup(email, phone, max_results)
        email_matches = email.blank? ? [] : email_search(email, max_results)
        phone_matches = phone.blank? ? [] : phone_search(phone, max_results)

        if email.blank? || phone.blank?
          email_matches + phone_matches
        else
          phone_ids = phone_matches.map(&:id)
          email_matches.select { |record| phone_ids.include?(record.id) }
        end
      end

      def email_search(email, max_results)
        definition = Elasticsearch::DSL::Search.search { query { match email: email } }
        definition.size = max_results
        VoterRecord.search(definition)
      end

      def phone_search(phone_number, max_results)
        definition =
          Elasticsearch::DSL::Search.search do
            query do
              constant_score do
                filter do
                  bool do
                    should { term phone: phone_number }
                    should { term vb_phone: phone_number }
                    should { term vb_phone_wireless: phone_number }
                    should { term ts_wireless_phone: phone_number }
                  end
                end
              end
            end
          end
        definition.size = max_results
        VoterRecord.search(definition)
      end
    end
  end
end
