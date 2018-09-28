RSpec.describe Queries::VoterRecord::ScoreFunctions::Name do
  let(:mocked_clause) { Search::Filter.new }

  describe described_class::First do
    let(:first_name) { 'Testy' }
    let(:alt_first_name) { 'Testerson' }

    describe '::synonym' do
      subject(:synonym) { described_class.synonym(first_name, alt_first_name) }

      let(:expected_boost_factor) { 5 }

      before do
        allow(Queries::VoterRecord::Clauses::Name::First).to(
          receive(:synonym) { mocked_clause },
        )
      end

      it 'calls the First::synonym clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Name::First).to(
          have_received(:synonym).
            with(an_instance_of(Search::Filter), first_name, alt_first_name),
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }
    end

    describe '::exact' do
      subject(:exact) { described_class.exact(first_name, alt_first_name) }
      let(:expected_boost_factor) { 2 }

      before do
        allow(Queries::VoterRecord::Clauses::Name::First).to(
          receive(:exact) { mocked_clause },
        )
      end

      it 'calls the First::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Name::First).to(
          have_received(:exact).
            with(an_instance_of(Search::Filter), first_name, alt_first_name),
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }
    end
  end

  describe described_class::Middle do
    describe '::is_missing' do
      subject(:is_missing) { described_class.is_missing }
      let(:expected_boost_factor) { 1 }
      let(:expected_filter) { { missing: { field: :middle_name } } }

      it do
        is_expected.to match(
          hash_including(
            boost_factor: expected_boost_factor,
            filter: expected_filter,
          ),
        )
      end
    end

    describe '::fuzzy' do
      subject(:fuzzy) { described_class.fuzzy(middle_name) }
      let(:expected_boost_factor) { 1 }
      let(:middle_name) { 'Quincy' }

      before do
        allow(Queries::VoterRecord::Clauses::Name::Middle).to(
          receive(:fuzzy) { mocked_clause },
        )
      end

      it 'calls the Middle::fuzzy clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Name::Middle).to(
          have_received(:fuzzy).with(an_instance_of(Search::Filter), middle_name),
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }
    end
  end
end
