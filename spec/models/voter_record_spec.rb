RSpec.describe VoterRecord do
  let(:voter_record) { build(:voter_record) }

  let(:es_client) { Elasticsearch::Client.new }
  let(:index) { 'index_name' }
  let(:doc_type) { 'doc_type' }

  before do
    allow(described_class).to receive(:client.to_sym).and_return(es_client)
    allow(described_class).to receive(:index).and_return(index)
    allow(described_class).to receive(:doc_type).and_return(doc_type)
  end

  describe '#==' do
    let(:document_id) { 'CA-123456' }
    let(:other_document_id) { 'NY-987654' }
    let(:voter_record) { build(:voter_record, id: document_id) }
    let(:other_voter_record) { build(:voter_record, id: other_document_id) }
    subject { voter_record == other_voter_record }

    context 'when they are the same object' do
      let(:other_voter_record) { voter_record }
      it { is_expected.to be true }
    end

    context 'when they have the same document id' do
      let(:other_voter_record) { build(:voter_record, id: document_id) }
      it { is_expected.to be true }
    end

    context 'when they do not have the same document id' do
      it { is_expected.to be false }
    end
  end

  describe '#method_missing' do
    context 'when the name is a key in the underlying document' do
      subject { voter_record.first_name }
      it { is_expected.to eq 'TESTY' }
    end

    context 'when the name is not a key in underlying document' do
      it 'should raise' do
        expect { voter_record.foo }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#to_thrift' do
    let(:expected_address_attributes) do
      {
        street: '524 THIRD ST',
        apt_number: '1',
        street_name: 'THIRD',
        ***REMOVED***
        unit_designator: 'SUITE',
        city: 'SAN FRANCISCO',
        state: ThriftShop::CivicData::StateCode::CA,
        zip_code: '94105',
      }
    end

    let(:expected_location_attributes) do
      {
        lat: '35.1868',
        lng: '-106.6652',
      }
    end

    let(:expected_general_election_attributes) do
      {
        '2012' => true,
        '2014' => true,
        '2016' => true,
      }
    end

    let(:expected_general_vote_types_attributes) do
      {
        '2012' => ThriftShop::Verification::VoteType::EARLY,
        '2014' => ThriftShop::Verification::VoteType::VOTED,
        '2016' => ThriftShop::Verification::VoteType::ABSENTEE,
      }
    end

    let(:expected_primary_vote_types_attributes) do
      {
        '2014' => ThriftShop::Verification::VoteType::NO_RECORD,
        '2016' => ThriftShop::Verification::VoteType::INELIGIBLE,
      }
    end

    let(:expected_scores_attributes) do
      {
        'activist' => 54.3,
        'campaign_finance' => 71.5,
        'catholic' => 16.5,
        'children_present' => 24.7,
        'climate_change' => 72.4,
        'college_funding' => 75.6,
        'college_graduate' => 52.6,
        'evangelical' => 23.0,
        'govt_privacy' => 66.9,
        'gun_control' => 75.6,
        'gunowner' => 57.4,
        'high_school_only' => 16.4,
        'ideology' => 60.3,
        'income_rank' => 85.0,
        'local_voter' => 22.0,
        'marriage' => 93.8,
        'midterm_general_turnout' => 88.2,
        'minimum_wage' => 72.8,
        'moral_authority' => 47.7,
        'moral_care' => 52.6,
        'moral_equality' => 39.1,
        'moral_equity' => 57.8,
        'moral_loyalty' => 49.2,
        'moral_purity' => 24.7,
        'non_presidential_primary_turnout' => 73.9,
        'nonchristian' => 27.3,
        'offyear_general_turnout' => 30.8,
        'otherchristian' => 33.2,
        'paid_leave' => 66.6,
        'partisan' => 98.4,
        'path_to_citizen' => 60.6,
        'presidential_general_turnout' => 86.7,
        'presidential_primary_turnout' => 81.3,
        'prochoice' => 67.4,
        'tax_on_wealthy' => 72.4,
        'teaparty' => 11.9,
        'trump_resistance' => 56.9,
        'trump_support' => 11.4,
        'veteran' => 44.0,
        'race_afam' => 1.6,
        'race_asian' => 0.8,
        'race_hisp' => 1.5,
        'race_natam' => 0.9,
        'race_white' => 95.2,
      }
    end

    let(:expected_attributes) do
      {
        id: 'CA-1234567',
        exact_track: 'Y12345678901234',
        first_name: 'TESTY',
        middle_name: 'QUINCY',
        last_name: 'MCTESTERSON',
        dob: '2014-08-01',
        party: ThriftShop::Verification::PoliticalParty::DEMOCRAT,
        registration_date: '2012-08-17',
        email: 'testy.mctesterson@example.com',
        email_append_level: ThriftShop::Verification::EmailMatchType::INDIVIDUAL,
        voter_score: ThriftShop::Verification::VoterScore::FREQUENT,
        num_general_election_votes: 3,
        num_primary_election_votes: 2,
        phone: '1234567890',
        vb_phone: '1234567891',
        vb_phone_type: ThriftShop::Verification::PhoneType::WIRELESS,
        ts_wireless_phone: '1234567892',
        vb_phone_wireless: '1234567893',
      }
    end

    subject { voter_record.to_thrift }

    it { is_expected.to be_a(ThriftShop::Verification::VoterRecord) }

    it { is_expected.to have_attributes(expected_attributes) }

    it 'has the right address attributes' do
      expect(subject.address).to have_attributes(expected_address_attributes)
    end

    it 'has the right location attributes' do
      expect(subject.location).to have_attributes(expected_location_attributes)
    end

    it 'has the right general_elections attributes' do
      expect(subject.general_elections).
        to match expected_general_election_attributes
    end

    it 'has the right general_vote_types attributes' do
      expect(subject.general_vote_types).
        to match expected_general_vote_types_attributes
    end

    it 'has the right primary_vote_types attributes' do
      expect(subject.primary_vote_types).
        to match expected_primary_vote_types_attributes
    end

    it 'has the right score attributes' do
      expect(subject.scores).
        to match expected_scores_attributes
    end

    context 'when registration_date is nil' do
      let(:voter_record) { build(:voter_record, registration_date: nil) }

      it { is_expected.to be_an_instance_of(ThriftShop::Verification::VoterRecord) }
      it { is_expected.to have_attributes(registration_date: nil) }
    end
  end

  describe '.get' do
    subject { described_class.get(id) }
    let(:id) { 'CA-123456' }

    let(:mocked_es_result) do
      { '_source' => { 'first_name' => 'Testy', 'last_name' => 'McTesterson' } }
    end

    before do
      allow(described_class).to receive(:new).with(mocked_es_result['_source']).and_call_original
      allow(es_client).to receive(:get).and_return(mocked_es_result)
    end

    it 'Calls the configured ES client' do
      subject
      expect(es_client).to have_received(:get).
        with(hash_including(id: id, index: index, type: doc_type))
    end

    context 'when the id matches a record' do
      before do
        allow(es_client).to receive(:get).and_return(mocked_es_result)
      end

      it { is_expected.to be_an_instance_of(described_class) }
      it do
        is_expected.to have_attributes(first_name: 'Testy', last_name: 'McTesterson')
      end
    end

    context 'when the id does not match a record' do
      before do
        allow(es_client).to receive(:get).and_return(false)
      end

      it { is_expected.to be_nil }
    end
  end

  describe '.search' do
    subject { described_class.search(query) }

    let(:query) do
      Elasticsearch::DSL::Search::Search.new { query { term last_name: 'McTesterson' } }
    end
    let(:mocked_hits) do
      [
        {
          '_score' => 12,
          '_source' => {
            'id' => 'CA-123456',
            'first_name' => 'Testy',
            'last_name' => 'McTesterson',
          },
        },
        {
          '_score' => 10,
          '_source' => {
            'id' => 'NY-987654',
            'first_name' => 'Testerson, Sr.',
            'last_name' => 'McTesterson',
          },
        },
      ]
    end
    let(:mocked_es_results) { { 'hits' => { 'hits' => mocked_hits } } }

    before do
      allow(described_class).to receive(:new).and_call_original
      allow(es_client).to receive(:search).and_return(mocked_es_results)
    end

    it 'Calls the configured ES client' do
      subject
      expect(es_client).to have_received(:search).
        with(hash_including(body: query, index: index, type: doc_type))
    end

    it do
      is_expected.to eq(
        [
          VoterRecord.new(mocked_hits[0]['_source'], score: mocked_hits[0]['_score']),
          VoterRecord.new(mocked_hits[1]['_source'], score: mocked_hits[1]['_score']),
        ],
      )
    end

    context 'when the query is nil' do
      let(:query) { nil }
      it { is_expected.to eq [] }
    end
  end
end
