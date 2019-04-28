# RPC handlers for getting pseudo-random addresses in a given state
class RandomAddressHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include ThriftUtils::Validation
  include ThriftUtils::EnumConversion

  process ThriftDefs::VoterVerifier::Service, only: %i[
    get_random_addresses
  ]

  handle :get_random_addresses do |_headers, request|
    query = Queries::VoterRecord::RandomAddress.new(
      state: thrift_to_state_code(enum: request.state),
      seed: request.seed,
    )
    addresses = VoterRecordAddress.search(query.offset_from_seed)

    ThriftDefs::GeoTypes::Addresses.new(
      addresses: addresses.map(&:to_thrift),
    )
  end
end
