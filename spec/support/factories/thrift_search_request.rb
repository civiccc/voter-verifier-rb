FactoryBot.define do
  factory :thrift_search_request,
          parent: :voter_search_query_args,
          class: ThriftShop::Verification::SearchRequest do
    max_results 3

    dob '2014-08-01'
    state ThriftShop::CivicData::StateCode::CA

    initialize_with { ThriftShop::Verification::SearchRequest.new attributes }
  end
end
