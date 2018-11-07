# RPC handlers for getting pseudo-random addresses in a given state
class RandomAddressHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include Validation
  include EnumConversion

  process ThriftShop::Verification::VerificationService, only: %i[
    get_random_addresses
  ]

  handle :get_random_addresses do |_headers, request|
    query = Queries::VoterRecord::RandomAddressQuery.new(
      state: thrift_to_state_code(enum: request.state),
      seed: request.seed,
    )
    addresses = VoterRecordAddress.search(query.build)

    ThriftShop::Verification::RandomAddresses.new(
      random_addresses: addresses.map(&:to_thrift),
    )
  end
end
