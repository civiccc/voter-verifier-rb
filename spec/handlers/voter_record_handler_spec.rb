RSpec.describe VoterRecordHandler do
  let(:handler) { described_class }

  let(:headers) do
    ThriftDefs::RequestTypes::Headers.new(
      entity: ThriftDefs::AuthTypes::Entity.new(
        uuid: '12345678-1234-1234-1234-123456781234',
        role: ThriftDefs::AuthTypes::EntityRole::USER,
      ),
    )
  end

  describe '#get_voter_records_by_identifiers' do
    subject { handler.get_voter_records_by_identifiers(headers, request) }

    let(:matching_voter_id) { 'CA-123456' }
    let(:multiple_matching_voter_ids) { [matching_voter_id, 'NY-987654'] }
    let(:non_matching_voter_id) { 'THISISNOTANID' }
    let(:voter_records) { multiple_matching_voter_ids.map { |id| build(:voter_record, id: id) } }
    let(:mock_model_get_result) { nil }
    let(:field_name) { :voter_records }
    let(:identifiers_field_name) { :voter_record_identifiers }

    let(:id_to_search) { '' }
    let(:request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(ids: [id_to_search]),
      )
    end

    let(:single_valid_request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(ids: [matching_voter_id]),
      )
    end

    let(:multiple_valid_request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(
            ids: multiple_matching_voter_ids,
          ),
      )
    end

    let(:multiple_mixed_request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(
            ids: [matching_voter_id, non_matching_voter_id],
          ),
      )
    end

    let(:multiple_invalid_request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(
            ids: [non_matching_voter_id, 'STILLNOTANID'],
          ),
      )
    end

    let(:nil_request) { ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new }
    let(:empty_request) do
      ThriftDefs::RequestTypes::GetVoterRecordsByIdentifiers.new(
        voter_record_identifiers:
          ThriftDefs::VoterRecordTypes::UniqueIdentifiers.new(ids: []),
      )
    end

    let(:single_valid_response) { [voter_records[0].to_thrift] }
    let(:multiple_valid_response) { voter_records.map(&:to_thrift) }
    let(:multiple_mixed_response) { [voter_records[0].to_thrift] }

    before do
      allow(VoterRecord).to receive(:get).and_return(nil)
      multiple_matching_voter_ids.each_with_index do |voter_id, i|
        allow(VoterRecord).to receive(:get).with(voter_id).and_return(voter_records[i])
      end
    end

    it_behaves_like 'gets resource by identifiers'

    it { is_expected.to be_a ThriftDefs::VoterRecordTypes::VoterRecords }

    it do
      is_expected.to have_attributes(
        voter_records: all(be_a(ThriftDefs::VoterRecordTypes::VoterRecord)),
      )
    end
  end
end
