require 'elasticsearch-dsl'

RSpec.describe Queries::VoterRecord::Clauses::Address do
  let(:parent_clause) { Elasticsearch::DSL::Search::Filter.new }

  describe described_class::City do
    let(:city) { 'Anytown' }

    describe('::exact') do
      subject(:exact) { described_class.exact(parent_clause, city).to_hash }
      let(:expected) do
        {
          query: {
            multi_match: {
              fields: %i[city ts_city],
              query: city,
              type: 'phrase',
            },
          },
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::LatLng do
    let(:lat) { '37.7808637' }
    let(:lng) { '-122.3954939' }

    describe '::within' do
      subject(:within) { described_class.within(parent_clause, distance, lat, lng).to_hash }
      let(:distance) { '1km' }
      let(:expected) do
        {
          or: [
            {
              geo_distance: {
                distance: distance,
                lat_lng_location: "#{lat},#{lng}",
              },
            },
            {
              geo_distance: {
                distance: distance,
                ts_lat_lng_location: "#{lat},#{lng}",
              },
            },
          ],
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::State do
    let(:state) { 'CA' }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, state).to_hash }
      let(:expected) do
        {
          query: {
            multi_match: {
              fields: %i[st ts_st],
              query: state,
            },
          },
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::StreetAddress do
    let(:street_address) { '***REMOVED***' }

    describe '::fuzzy' do
      subject(:fuzzy) { described_class.fuzzy(parent_clause, street_address).to_hash }
      let(:expected) do
        {
          query: {
            multi_match: {
              fields: %i[address ts_address],
              query: street_address,
              slop: 2,
              type: 'phrase',
            },
          },
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::ZipCode do
    let(:zip_code) { '94105' }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, zip_code).to_hash }
      let(:expected) do
        {
          query: {
            multi_match: {
              fields: %i[zip_code ts_zip_code],
              query: zip_code,
            },
          },
        }
      end

      it { is_expected.to eq expected }
    end
  end
end
