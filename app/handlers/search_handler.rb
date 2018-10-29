# RPC handlers for searching voting vecords
class SearchHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include EnumConversion
  include Validation

  process ThriftShop::Verification::VerificationService, only: %i[search]

  handle :search do |_headers, request|
    verify_field_presence(field: 'last_name', thrift_object: request)
    verify_field_presence(field: 'max_results', thrift_object: request)

    begin
      parsed_dob = Date.parse(request.dob)
    # TypeError when request.dob is nil, ArgumentError when it's invalid as a date
    rescue TypeError, ArgumentError
      parsed_dob = nil
    end

    matches = VoterVerification::Search.new(
      {
        last_name: request.last_name,
        first_name: request.first_name,
        middle_name: request.middle_name,

        dob: parsed_dob,
        email: request.email,
        phone: request.phone,

        street_address: request.street_address,
        city: request.city,
        state: thrift_to_state_code(enum: request.state),
        zip_code: request.zip_code,

        max_results: request.max_results,
      },
      smart_search: true,
    ).run

    ThriftShop::Verification::VoterRecords.new(
      voter_records: matches.map(&:to_thrift),
    )
  end
end
