require 'elasticsearch-dsl'

RSpec.describe Queries::VoterRecord::Clauses::Email do
  let(:parent_clause) { Elasticsearch::DSL::Search::Query.new }
  let(:email) { 'testy.mctesterson@example.com' }

  describe '::exact' do
    subject(:exact) { described_class.exact(parent_clause, email).to_hash }
    let(:expected) do
      {
        match: {
          email: email,
        },
      }
    end

    it { is_expected.to eq expected }
  end
end
