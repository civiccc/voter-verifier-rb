# RPC handlers for searching voting records
class VoterRecordSearchHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include ThriftUtils::EnumConversion
  include ThriftUtils::Validation

  process ThriftDefs::VoterVerifier::Service, only: %i[search contact_search]

  handle :search do |_headers, request|
    verify_field_presence(field: 'max_results', thrift_object: request)
    verify_at_least_one_field_present(%i[last_name email phone], request)

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
      max_results: request.max_results || configatron.search.default_max_results,
      smart_search: true,
    ).run

    thrift_matches = matches.map(&:to_thrift).each { |record| record.auto_verify = auto_verify }

    ThriftDefs::VoterRecordTypes::VoterRecords.new(
      voter_records: thrift_matches,
    )
  end

  handle :contact_search do |_headers, request|
    verify_at_least_one_field_present(%i[email phone], request)

    max_results = request.max_results || configatron.search.contact.default_max_results
    phone = Queries::VoterRecord::Preprocessors::Phone.preprocess(request.phone)

    matches = VoterVerification::ContactSearch.lookup(request.email, phone, max_results)
    thrift_matches = matches.map(&:to_thrift)
    ThriftDefs::VoterRecordTypes::VoterRecords.new(voter_records: thrift_matches)
  end


end
