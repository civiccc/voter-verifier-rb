RSpec.describe VoterRecordSearchHandler do
  let(:handler) { described_class }

  let(:headers) do
    ThriftDefs::RequestTypes::Headers.new(
      entity: ThriftDefs::AuthTypes::Entity.new(
        uuid: SecureRandom.uuid,
        role: ThriftDefs::AuthTypes::EntityRole::USER,
      ),
    )
  end

  let(:request) do
    ThriftDefs::RequestTypes::ContactSearch.new(
      email: email,
      phone: raw_phone,
      max_results: max_results,
    )
  end

  let(:email) { nil }
  let(:raw_phone) { nil }
  let(:phone) { raw_phone }
  let(:max_results) { 5 }

  let(:voter_record_1) { build(:voter_record, id: 'id1') }
  let(:voter_record_2) { build(:voter_record, id: 'id2') }
  let(:voter_record_3) { build(:voter_record, id: 'id3') }
  let(:voter_record_4) { build(:voter_record, id: 'id4') }
  let(:voter_record_5) { build(:voter_record, id: 'id5') }
  let(:email_matches) { [voter_record_1, voter_record_2, voter_record_3] }
  let(:phone_matches) { [voter_record_1, voter_record_3, voter_record_4, voter_record_5] }

  describe '#contact_search' do
    subject(:results) { handler.contact_search(headers, request).voter_records }

    context 'invalid request' do
      it 'throws an exception' do
        expect { subject }.to raise_error(ThriftDefs::ExceptionTypes::ArgumentException)
      end
    end

    context 'only email requested' do
      let(:email) { 'dt@llareggub.wales' }

      before { allow(VoterRecord).to receive(:search).and_return(email_matches) }

      it 'returns the email matches' do
        expect(results.map(&:id).sort).to eq email_matches.map(&:id).sort
      end
    end

    context 'only phone requested' do
      let(:raw_phone) { '0123456789' }
      before { allow(VoterRecord).to receive(:search).and_return(phone_matches) }

      it 'returns the phone matches' do
        expect(results.map(&:id).sort).to eq phone_matches.map(&:id).sort
      end
    end

    context 'only phone with prefix requested' do
      let(:raw_phone) { '+10123456789' }
      let(:phone) { '0123456789' }
      before { allow(VoterRecord).to receive(:search).and_return(phone_matches) }

      it 'returns the phone matches' do
        expect(results.map(&:id).sort).to eq phone_matches.map(&:id).sort
      end
    end

    context 'both email and phone requested' do
      let(:email) { 'dt@llareggub.wales' }
      let(:raw_phone) { '0123456789' }
      before { allow(VoterRecord).to receive(:search).and_return(email_matches & phone_matches) }

      it 'returns the intersection' do
        expect(results.map(&:id).sort).to eq ['id1', 'id3']
      end
    end
  end
end
