RSpec.describe Queries::VoterRecord::RandomAddressQuery do
  let(:limit) { 10 }
  let(:state) { 'CA' }
  let(:seed) { '42' }
  let(:random_address_query) { described_class.new(state: state, seed: seed, limit: 10) }

  describe '#build' do
    subject { random_address_query.build }

    before do
      allow(Queries::VoterRecord::Clauses::Address::State).to(
        receive(:exact).and_call_original,
      )
    end

    it { is_expected.to be_a(Elasticsearch::DSL::Search::Search) }

    it do
      subject
      expect(Queries::VoterRecord::Clauses::Address::State).to(
        have_received(:exact).
        with(an_instance_of(Elasticsearch::DSL::Search::Search), state),
      )
    end

    it { expect(subject.to_hash).to include(size: limit, from: seed.to_i) }
  end
end
