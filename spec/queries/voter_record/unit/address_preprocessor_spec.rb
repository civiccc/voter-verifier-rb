RSpec.describe Queries::VoterRecord::Preprocessors::Address do
  let(:street_address) { '***REMOVED***' }
  let(:city) { 'Portsmouth' }
  let(:state) { 'NH' }
  let(:zip_code_plus_4) { '00210-1234' }
  let(:zip_code_5) { '00210' }
  let(:lat) { '43.0059' }
  let(:lng) { '-71.0132' }

  describe '::preprocess' do
    subject { described_class.preprocess(street_address, city, state, zip_code_5) }

    context 'When the zip code can be geocoded' do
      it { is_expected.to match hash_including(lat: lat, lng: lng) }
    end

    context 'When the zip code cannot be geocoded' do
      let(:zip_code_5) { '00000' }

      it { is_expected.to match hash_including(lat: nil, lng: nil) }
    end

    context 'when a zip+4 is given' do
      subject { described_class.preprocess(street_address, city, state, zip_code_plus_4) }

      it { is_expected.to match hash_including(lat: lat, lng: lng, zip_code: zip_code_5) }
    end

    context 'when a lowercase state is given' do
      let(:state) { 'nh' }

      it { is_expected.to match hash_including(state: state.upcase) }
    end
  end
end
