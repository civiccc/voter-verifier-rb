# RPC handlers for operating on voting records
class VoterRecordHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include ThriftUtils::Validation

  process ThriftDefs::VoterVerifier::Service, only: %i[
    get_voter_records_by_identifiers
  ]

  handle :get_voter_records_by_identifiers do |_headers, request|
    verify_field_presence(field: :voter_record_identifiers, thrift_object: request)
    # TODO multi get API if actually looking for multiple records at once
    records =
      case request.voter_record_identifiers.get_set_field
      when :ids
        request.voter_record_identifiers.ids.
          map { |voter_record_id| VoterRecord.get(voter_record_id) }.
          reject(&:nil?).
          map(&:to_thrift)
      else
        raise ThriftDefs::ExceptionTypes::ArgumentException,
              message: 'Invalid type of voter record identifier',
              path: 'request.voter_record_identifiers',
              code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::INVALID
      end
    ThriftDefs::VoterRecordTypes::VoterRecords.new(voter_records: records)
  end
end
