# RPC handlers for searching voting records
class VoterRecordSearchHandler < ThriftServer::ThriftHandler
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

    matches, auto_verify = VoterVerification::Search.new(
      query_args: {
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
      },
      max_results: request.max_results,
      smart_search: true,
    ).run

    thrift_matches = matches.map(&:to_thrift).each { |record| record.auto_verify = auto_verify }

    ThriftShop::Verification::VoterRecords.new(
      voter_records: thrift_matches,
    )
  end
end
