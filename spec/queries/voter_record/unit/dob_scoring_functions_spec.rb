RSpec.describe Queries::VoterRecord::ScoreFunctions::DOB do
  let(:mocked_clause) { Search::Filter.new }

  describe described_class::Day do
    let(:day) { 15 }

    describe '::exact_or_missing_or_is_first' do
      subject(:exact_or_missing_or_is_first) { described_class.exact_or_missing_or_is_first(day) }

      let(:mocked_exact) { 'mocked exact' }
      let(:mocked_is_missing) { 'mocked is_missing' }
      let(:mocked_missing_or_is_first) { 'mocked missing_or_is_first' }

      before do
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Day).to receive(:exact) { mocked_exact }
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Day).to(
          receive(:is_missing) { mocked_is_missing },
        )
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Day).to(
          receive(:missing_or_is_first) { mocked_missing_or_is_first },
        )
      end

      context 'when value is 1' do
        let(:day) { 1 }

        it 'calls the exact score function' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Day).to have_received(:exact).with(day)
        end

        it 'calls the Day::is_missing clause' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Day).to(
            have_received(:is_missing).with(no_args),
          )
        end

        it { is_expected.to match_array [mocked_exact, mocked_is_missing] }
      end

      context 'when value is > 1' do
        let(:day) { 15 }

        it 'calls the exact score function' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Day).to have_received(:exact).with(day)
        end

        it 'calls the Day::missing_or_is_first clause' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Day).to(
            have_received(:missing_or_is_first).with(no_args),
          )
        end

        it { is_expected.to match_array [mocked_exact, mocked_missing_or_is_first] }
      end
    end

    describe '::exact' do
      subject(:exact) { described_class.exact(day) }
      let(:expected_boost_factor) { 2 }

      before { allow(Queries::VoterRecord::Clauses::DOB::Day).to receive(:exact) { mocked_clause } }

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }

      it 'calls the Day::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::DOB::Day).to(
          have_received(:exact).with(an_instance_of(Search::Filter), day),
        )
      end
    end

    describe '::is_missing' do
      subject(:is_missing) { described_class.is_missing }

      let(:expected_boost_factor) { 1 }
      let(:expected_filter) { { missing: { field: :dob_day } } }

      it do
        is_expected.to match(
           hash_including(
             boost_factor: expected_boost_factor,
             filter: expected_filter,
           ),
         )
      end
    end

    describe '::missing_or_is_first' do
      subject(:is_missing) { described_class.missing_or_is_first }
      let(:expected_boost_factor) { 1 }

      before do
        allow(Queries::VoterRecord::Clauses::DOB::Day).to(
          receive(:missing_or_is_first) { mocked_clause },
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }

      it 'calls the Day::missing_or_is_first clause' do
        subject
        expect(Queries::VoterRecord::Clauses::DOB::Day).to(
          have_received(:missing_or_is_first).with(an_instance_of(Search::Filter)),
        )
      end
    end
  end

  describe described_class::Month do
    let(:month) { 6 }

    describe '::exact_or_missing_or_is_first' do
      subject(:exact_or_missing_or_is_first) { described_class.exact_or_missing_or_is_first(month) }

      let(:mocked_exact) { 'mocked exact' }
      let(:mocked_is_missing) { 'mocked is_missing' }
      let(:mocked_missing_or_is_first) { 'mocked missing_or_is_first' }

      before do
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Month).to receive(:exact) { mocked_exact }
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
            receive(:is_missing) { mocked_is_missing },
        )
        allow(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
          receive(:missing_or_is_first) { mocked_missing_or_is_first },
        )
      end

      context 'when value is 1' do
        let(:month) { 1 }

        it 'calls the exact score function' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
            have_received(:exact).with(month),
          )
        end

        it 'calls the missing_or_is_first' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
            have_received(:is_missing).with(no_args),
          )
        end

        it { is_expected.to match_array [mocked_exact, mocked_is_missing] }
      end

      context 'when value is > 1' do
        let(:month) { 6 }

        it 'calls the exact score function' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
            have_received(:exact).with(month),
          )
        end

        it 'calls the missing_or_is_first' do
          subject
          expect(Queries::VoterRecord::ScoreFunctions::DOB::Month).to(
            have_received(:missing_or_is_first).with(no_args),
          )
        end

        it { is_expected.to match_array [mocked_exact, mocked_missing_or_is_first] }
      end
    end

    describe '::exact' do
      subject(:exact) { described_class.exact(month) }
      let(:expected_boost_factor) { 5 }

      before do
        allow(Queries::VoterRecord::Clauses::DOB::Month).to(
          receive(:exact) { mocked_clause },
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }

      it 'calls the Day::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::DOB::Month).to(
          have_received(:exact).with(an_instance_of(Search::Filter), month),
        )
      end
    end

    describe '::is_missing' do
      subject(:is_missing) { described_class.is_missing }
      let(:expected_boost_factor) { 1 }
      let(:expected_filter) { { missing: { field: :dob_month } } }

      it do
        is_expected.to match(
          hash_including(
             boost_factor: expected_boost_factor,
             filter: expected_filter,
          ),
        )
      end
    end

    describe '::missing_or_is_first' do
      subject(:exact) { described_class.missing_or_is_first }
      let(:expected_boost_factor) { 1 }

      before do
        allow(Queries::VoterRecord::Clauses::DOB::Month).to(
          receive(:missing_or_is_first) { mocked_clause },
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }

      it 'calls the Day::missing_or_is_first clause' do
        subject
        expect(Queries::VoterRecord::Clauses::DOB::Month).to(
          have_received(:missing_or_is_first).with(an_instance_of(Search::Filter)),
        )
      end
    end
  end

  describe described_class::Year do
    let(:year) { 2014 }

    describe '::exact' do
      subject(:exact) { described_class.exact(year) }
      let(:expected_boost_factor) { 5 }

      before do
        allow(Queries::VoterRecord::Clauses::DOB::Year).to(
          receive(:exact) { mocked_clause },
        )
      end

      it 'calls the Year::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::DOB::Year).to(
          have_received(:exact).with(an_instance_of(Search::Filter), year),
        )
      end

      it { is_expected.to match(hash_including(boost_factor: expected_boost_factor)) }
    end

    describe '::is_missing' do
      subject(:is_missing) { described_class.is_missing }
      let(:expected_boost_factor) { 1 }
      let(:expected_filter) { { missing: { field: :dob_year } } }

      it do
        is_expected.to match(
          hash_including(
            boost_factor: expected_boost_factor,
            filter: expected_filter,
          ),
        )
      end
    end
  end
end
