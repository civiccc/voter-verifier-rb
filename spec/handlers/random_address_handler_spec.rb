RSpec.describe RandomAddressHandler do
  subject(:handler) { described_class }

  let(:headers) do
    ThriftShop::Shared::RequestHeaders.new(
      entity: ThriftShop::Shared::Entity.new(
        uuid: '12345678-1234-1234-1234-123456781234',
        role: ThriftShop::Shared::EntityRole::USER,
      ),
    )
  end

  let(:request) do
    ThriftShop::Verification::RandomAddressRequest.new(
      state: ThriftShop::CivicData::StateCode::CA,
      seed: 42,
    )
  end

  let(:address) { build(:voter_record_address) }

  describe '#get_random_addresses' do
    subject { handler.get_random_addresses(headers, request) }

    shared_examples 'has an array of addresses' do
      it { expect(subject.random_addresses).to(match_array([address.to_thrift])) }
    end

    context 'when request is valid' do
      before do
        allow(VoterRecordAddress).to(receive(:search).and_return([address]))
      end

      it 'calls VoterRecordAddress#search' do
        expect(VoterRecordAddress).to(receive(:search).and_return([address]))
        subject
      end

      it_behaves_like 'has an array of addresses'
    end
  end
end
