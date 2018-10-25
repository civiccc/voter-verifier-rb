RSpec.describe VoterRecord do
  subject(:voter_record) { build(:voter_record) }

  describe '#to_thrift' do
    it { should respond_to(:to_thrift) }
  end

  describe '.search' do
    subject { described_class.search(query) }
    let(:es_client) { Elasticsearch::Client.new }
    let(:index) { 'index_name' }
    let(:doc_type) { 'doc_type' }

    let(:query) do
      Elasticsearch::DSL::Search::Search.new { query { term last_name: 'McTesterson' } }
    end

    let(:mocked_hits) do
      [
        { '_source' => { 'first_name' => 'Testy', 'last_name' => 'McTesterson' } },
        { '_source' => { 'first_name' => 'Testerson, Sr.', 'last_name' => 'McTesterson' } },
      ]
    end

    let(:mocked_es_results) { { 'hits' => { 'hits' => mocked_hits } } }

    before do
      allow(es_client).to receive(:search).and_return(mocked_es_results)
      allow(described_class).to receive(:client.to_sym).and_return(es_client)
      allow(described_class).to receive(:index).and_return(index)
      allow(described_class).to receive(:doc_type).and_return(doc_type)
    end

    it 'Calls the configured ES client' do
      subject
      expect(es_client).to have_received(:search).
        with(hash_including(body: query, index: index, type: doc_type))
    end
  end
end
