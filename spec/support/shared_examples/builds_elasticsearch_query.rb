shared_examples 'builds an elasticsearch query' do
  it { is_expected.to be_an_instance_of Elasticsearch::DSL::Search::Search }
end
