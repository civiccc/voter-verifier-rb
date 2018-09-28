RSpec.describe Queries::VoterRecord::ScoreFunctions::Email do
  let(:mocked_clause) { Search::Filter.new }

  describe '::exact' do
    subject(:exact) { described_class.exact(email) }
    let(:email) { 'testy.mctesterson@example.com' }
    let(:expected_boost_factor) { 5 }

    before { allow(Queries::VoterRecord::Clauses::Email).to receive(:exact) { mocked_clause } }

    it 'calls the Email::exact clause' do
      subject
      expect(Queries::VoterRecord::Clauses::Email).to(
        have_received(:exact).with(instance_of(Search::Filter), email),
      )
    end

    it { is_expected.to match(a_hash_including(boost_factor: expected_boost_factor)) }
  end
end
