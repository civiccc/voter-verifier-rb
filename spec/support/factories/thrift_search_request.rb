FactoryBot.define do
  factory :thrift_search_request,
          parent: :search_query_args,
          class: ThriftShop::Verification::SearchRequest do
    after(:build) { |request| request.dob = request.dob.iso8601 }
    initialize_with { ThriftShop::Verification::SearchRequest.new attributes }
  end
end
