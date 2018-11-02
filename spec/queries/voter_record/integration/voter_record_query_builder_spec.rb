RSpec.describe Queries::VoterRecord::Query do
  shared_examples 'builds an elasticsearch query' do
    it { is_expected.to be_an_instance_of Elasticsearch::DSL::Search::Search }
  end

  let(:first_name) { 'Testy' }
  let(:middle_name) { 'Q' }
  let(:last_name) { 'McTesterson' }
  let(:alt_first_name) { 'Testerson' }
  let(:alt_last_name) { 'MacTesterson' }
  let(:alt_middle_name) { 'Quincy' }
  let(:dob) { Time.new 2014, 8, 1 }
  let(:street_address) { '***REMOVED***' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }
  let(:zip_code) { '94105' }

  subject do
    described_class.new(
      size: 3,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      alt_first_name: alt_first_name,
      alt_middle_name: alt_middle_name,
      alt_last_name: alt_last_name,
      dob: dob,
      street_address: street_address,
      city: city,
      state: state,
      zip_code: zip_code,
    )
  end

  describe '#auto' do
    subject { super().auto }

    context 'with all fields provided' do
      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with no alt names provided' do
      let(:alt_first_name) { nil }
      let(:alt_middle_name) { nil }
      let(:alt_last_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil first and middle names' do
      let(:first_name) { nil }
      let(:middle_name) { nil }

      it { is_expected.to be_nil }
    end

    context 'with nil first name' do
      let(:first_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil middle name' do
      let(:middle_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil dob' do
      let(:dob) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil zip code' do
      let(:zip_code) { nil }

      it_behaves_like 'builds an elasticsearch query'

      context 'with nil street address' do
        let(:street_address) { nil }

        it_behaves_like 'builds an elasticsearch query'
      end

      context 'with nil city/state' do
        let(:city) { nil }
        let(:state) { nil }

        it_behaves_like 'builds an elasticsearch query'
      end
    end

    context 'with nil lat' do
      let(:lat) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with both dob and zip code nil' do
      let(:zip_code) { nil }
      let(:dob) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#top' do
    subject { super().top }

    context 'with all fields provided' do
      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil first and middle names' do
      let(:first_name) { nil }
      let(:middle_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil first name' do
      let(:first_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil middle name' do
      let(:middle_name) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil dob' do
      let(:dob) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end

    context 'with nil zip code' do
      let(:zip_code) { nil }

      it_behaves_like 'builds an elasticsearch query'

      context 'with nil street address' do
        let(:street_address) { nil }

        it_behaves_like 'builds an elasticsearch query'
      end

      context 'with nil city/state' do
        let(:city) { nil }
        let(:state) { nil }

        it_behaves_like 'builds an elasticsearch query'
      end
    end

    context 'with nil lat' do
      let(:lat) { nil }

      it_behaves_like 'builds an elasticsearch query'
    end
  end
end
