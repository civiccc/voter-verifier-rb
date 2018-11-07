require 'elasticsearch-dsl'

RSpec.describe Queries::VoterRecord::Clauses::Name do
  let(:parent_clause) { Elasticsearch::DSL::Search::Filter.new }

  describe described_class::First do
    let(:first_name) { 'Testy' }
    let(:alt_first_name) { 'Testerson' }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, first_name, alt_first_name).to_hash }

      def expected_query_for_value(value)
        {
          query: {
            match_phrase: {
              first_name: value,
            },
          },
        }
      end

      context 'when no alt_value is given' do
        let(:expected) { expected_query_for_value(first_name) }
        let(:alt_first_name) { nil }

        it { is_expected.to eq expected }
      end

      context 'when alt_value is given' do
        let(:or_query_with_value_and_alt_value) do
          {
            or: [
              expected_query_for_value(first_name),
              expected_query_for_value(alt_first_name),
            ],
          }
        end

        it { is_expected.to eq or_query_with_value_and_alt_value }
      end
    end

    describe '::synonym' do
      def expected_query_for_value(value)
        {
          or: [
            {
              query: {
                multi_match: {
                  analyzer: Queries::VoterRecord::Clauses::Name::Analyzers::FIRST,
                  type: 'phrase',
                  query: value,
                  fields: %i[first_name middle_name],
                },
              },
            },
            {
              query: {
                multi_match: {
                  analyzer: Queries::VoterRecord::Clauses::Name::Analyzers::COMPACT,
                  type: 'phrase',
                  query: value,
                  fields: %i[first_name_compact middle_name_compact],
                },
              },
            },
          ],
        }
      end

      subject(:first_synonym) do
        described_class.synonym(parent_clause, first_name, alt_first_name).to_hash
      end

      context 'when no alt_value is given' do
        let(:alt_first_name) { nil }
        let(:expected) { expected_query_for_value(first_name) }

        it { is_expected.to eq expected }
      end

      context 'when alt_value is given' do
        let(:expected) do
          {
            or: [
              expected_query_for_value(first_name),
              expected_query_for_value(alt_first_name),
            ],
          }
        end

        it { is_expected.to eq expected }
      end
    end
  end

  describe described_class::Last do
    let(:last_name) { 'McTesterson' }
    let(:alt_last_name) { 'MacTesterson' }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, last_name, alt_last_name).to_hash }

      def expected_query_for_value(value)
        {
          or: [
            {
              query: {
                match: {
                  last_name: value,
                },
              },
            },
            {
              query: {
                match: {
                  last_name_compact: {
                    analyzer: Queries::VoterRecord::Clauses::Name::Analyzers::COMPACT,
                    query: value,
                  },
                },
              },
            },
          ],
        }
      end

      context 'when no alt_value is given' do
        let(:expected) { expected_query_for_value(last_name) }
        let(:alt_last_name) { nil }

        it { is_expected.to eq expected }
      end

      context 'when alt_value is given' do
        let(:expected) do
          {
            or: [
              expected_query_for_value(last_name),
              expected_query_for_value(alt_last_name),
            ],
          }
        end

        it { is_expected.to eq expected }
      end
    end
  end

  describe described_class::Middle do
    describe '::fuzzy' do
      subject(:fuzzy) { described_class.fuzzy(parent_clause, middle_name).to_hash }

      context 'when an initial is given' do
        let(:middle_name) { 'Q' }
        let(:expected) do
          {
            query: {
              prefix: {
                middle_name: middle_name.downcase,
              },
            },
          }
        end

        it { is_expected.to eq expected }
      end

      context 'when a full name is given' do
        let(:middle_name) { 'Quincy' }
        let(:expected) do
          {
            or: [
              {
                query: {
                  match_phrase: {
                    middle_name: {
                      analyzer: Queries::VoterRecord::Clauses::Name::Analyzers::FIRST,
                      query: middle_name,
                    },
                  },
                },
              },
              {
                query: {
                  match_phrase: {
                    middle_name_compact: {
                      analyzer: Queries::VoterRecord::Clauses::Name::Analyzers::COMPACT,
                      query: middle_name,
                    },
                  },
                },
              },
              {
                query: {
                  multi_match: {
                    query: middle_name[0],
                    fields: %i[middle_name middle_name_compact],
                  },
                },
              },
            ],
          }
        end

        it { is_expected.to eq expected }
      end
    end
  end
end
