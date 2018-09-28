RSpec.describe Queries::VoterRecord::ScoreFunctions::Address do
  let(:mocked_clause) { Search::Filter.new }

  describe described_class::Full do
    let(:city) { 'Anytown' }
    let(:state) { 'CA' }

    describe '::city_state' do
      subject(:city_state) { described_class.city_state(city, state) }
      let(:expected_boost_factor) { 2 }

      before do
        allow(Queries::VoterRecord::Clauses::Address::City).to receive(:exact) { mocked_clause }
        allow(Queries::VoterRecord::Clauses::Address::State).to receive(:exact) { mocked_clause }
      end

      it 'calls the City::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::City).to(
          have_received(:exact).with(instance_of(Search::Filters::And), city),
        )
      end

      it 'calls the State::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::State).to(
          have_received(:exact).with(instance_of(Search::Filters::And), state),
        )
      end

      it { is_expected.to match(a_hash_including(boost_factor: expected_boost_factor)) }
    end

    describe '::street_city_and_state' do
      subject(:city_state) { described_class.street_city_and_state(street_address, city, state) }
      let(:street_address) { '***REMOVED***' }
      let(:expected_boost_factor) { 3 }

      before do
        allow(Queries::VoterRecord::Clauses::Address::City).to receive(:exact) { mocked_clause }
        allow(Queries::VoterRecord::Clauses::Address::State).to receive(:exact) { mocked_clause }
        allow(Queries::VoterRecord::Clauses::Address::StreetAddress).to(
          receive(:fuzzy) { mocked_clause },
        )
      end

      it 'calls the City::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::City).to(
          have_received(:exact).with(instance_of(Search::Filters::And), city),
        )
      end

      it 'calls the State::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::State).to(
          have_received(:exact).with(instance_of(Search::Filters::And), state),
        )
      end

      it 'calls the StreetAddress::fuzzy clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::StreetAddress).to(
          have_received(:fuzzy).with(instance_of(Search::Filters::And), street_address),
        )
      end

      it { is_expected.to match(a_hash_including(boost_factor: expected_boost_factor)) }
    end
  end

  describe described_class::ZipCode do
    let(:zip_code) { '94105' }

    describe '::exact' do
      subject(:exact) { described_class.exact(zip_code) }
      let(:expected_boost_factor) { 1 }

      before do
        allow(Queries::VoterRecord::Clauses::Address::ZipCode).to(
          receive(:exact) { mocked_clause },
        )
      end

      it 'calls the ZipCode::exact clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::ZipCode).to(
          have_received(:exact).with(instance_of(Search::Filter), zip_code),
        )
      end

      it { is_expected.to match(a_hash_including(boost_factor: expected_boost_factor)) }
    end
  end

  describe described_class::LatLng do
    let(:lat) { '37.7808637' }
    let(:lng) { '-122.3954939' }

    describe '::within' do
      subject(:within) { described_class.within(distance, lat, lng) }
      let(:distance) { '1km' }
      let(:expected_boost_factor) { 6 }

      before do
        allow(Queries::VoterRecord::Clauses::Address::LatLng).to(
          receive(:within) { mocked_clause },
        )
      end

      it 'calls the LatLng::within clause' do
        subject
        expect(Queries::VoterRecord::Clauses::Address::LatLng).to(
          have_received(:within).with(instance_of(Search::Filter), distance, lat, lng),
        )
      end

      it { is_expected.to match(a_hash_including(boost_factor: expected_boost_factor)) }
    end
  end
end
