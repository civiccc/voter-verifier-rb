FactoryBot.define do
  factory :thrift_search_request,
          parent: :voter_search_query_args,
          class: ThriftDefs::RequestTypes::Search do
    max_results 3

    dob '2014-08-01'
    # TODO CivicData won't be the namespace for this anymore
    state ThriftDefs::GeoTypes::StateCode::CA

    initialize_with { ThriftDefs::RequestTypes::Search.new attributes }
  end
end
