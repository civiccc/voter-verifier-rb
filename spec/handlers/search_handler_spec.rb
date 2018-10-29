RSpec.describe SearchHandler do
  subject(:handler) { described_class }

  let(:headers) do
    ThriftShop::Shared::RequestHeaders.new(
      entity: ThriftShop::Shared::Entity.new(
        uuid: '12345678-1234-1234-1234-123456781234',
        role: ThriftShop::Shared::EntityRole::USER,
      ),
    )
  end

  let(:request) { build(:thrift_search_request) }
  let(:voter_record) { build(:voter_record) }

  describe '#search' do
    subject { handler.search(headers, request) }

    shared_examples 'has an array of voter records' do
      it do
        expect(subject.voter_records).
          to(match all(an_instance_of(ThriftShop::Verification::VoterRecord)))
      end
    end

    context 'when request is valid' do
      before do
        allow_any_instance_of(VoterVerification::Search).to receive(:run).and_return([voter_record])
      end

      it 'calls SearchService#run' do
        expect_any_instance_of(VoterVerification::Search).to(
          receive(:run).and_return([voter_record]),
        )
        subject
      end

      it { is_expected.to be_an_instance_of(ThriftShop::Verification::VoterRecords) }

      it 'has an array of thrift voter records' do
        expect(subject.voter_records).
          to(match all(an_instance_of(ThriftShop::Verification::VoterRecord)))
      end
    end

    context 'when request is not valid' do
      shared_examples 'raises an argument exception' do
        it { expect { subject }.to raise_error(ThriftShop::Shared::ArgumentException) }
      end

      context 'because last_name is nil' do
        let(:request) { build(:thrift_search_request, last_name: nil) }
        it_behaves_like 'raises an argument exception'
      end

      context 'because max_results is nil' do
        let(:request) { build(:thrift_search_request, max_results: nil) }
        it_behaves_like 'raises an argument exception'
      end
    end
  end
end
