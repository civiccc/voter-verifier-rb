# RPC handlers for operating on voting records
class VoterRecordHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin
  include Validation

  process ThriftShop::Verification::VerificationService, only: %i[
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
        raise ThriftShop::Shared::ArgumentException,
              message: 'Invalid type of voter record identifier',
              path: 'request.voter_record_identifiers',
              code: ThriftShop::Shared::ArgumentExceptionCode::INVALID
      end
    ThriftShop::Verification::VoterRecords.new(voter_records: records)
  end
end
