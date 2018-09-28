RSpec.describe Queries::VoterRecord::Clauses::DOB do
  let(:parent_clause) { Search::Filter.new }

  describe described_class::Day do
    let(:day) { 2 }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, day).to_hash }
      let(:expected) do
        {
          term: {
            dob_day: day,
          },
        }
      end

      it { is_expected.to eq expected }
    end

    describe '::missing_or_is_first' do
      subject(:missing_or_is_first) { described_class.missing_or_is_first(parent_clause).to_hash }
      let(:expected) do
        {
          or: [
            {
              term: {
                dob_day: 1,
              },
            },
            {
              missing: {
                field: :dob_day,
              },
            },
          ],
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::Month do
    let(:month) { 8 }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, month).to_hash }
      let(:expected) do
        {
          term: {
            dob_month: month,
          },
        }
      end

      it { is_expected.to eq expected }
    end

    describe '::missing_or_is_first' do
      subject(:missing_or_is_first) { described_class.missing_or_is_first(parent_clause).to_hash }
      let(:expected) do
        {
          or: [
            {
              missing: {
                field: :dob_month,
              },
            },
            {
              and: [
                {
                  term: {
                    dob_month: 1,
                  },
                },
                {
                  term: {
                    dob_day: 1,
                  },
                },
              ],
            },
          ],
        }
      end

      it { is_expected.to eq expected }
    end
  end

  describe described_class::Year do
    let(:year) { 2014 }

    describe '::exact' do
      subject(:exact) { described_class.exact(parent_clause, year).to_hash }
      let(:expected) do
        {
          term: {
            dob_year: year,
          },
        }
      end

      it { is_expected.to eq expected }
    end

    describe '::fuzzy' do
      subject(:fuzzy) { described_class.fuzzy(parent_clause, year).to_hash }
      let(:expected) do
        {
          or: [
            {
              missing: {
                field: :dob_year,
              },
            },
            {
              range: {
                dob_year: {
                  gte: year - 1,
                  lte: year + 1,
                },
              },
            },
          ],
        }
      end

      it { is_expected.to eq expected }
    end

    describe '::missing_or_exact' do
      subject(:missing_or_exact) { described_class.missing_or_exact(parent_clause, year).to_hash }
      let(:expected) do
        {
          or: [
            {
              missing: {
                field: :dob_year,
              },
            },
            {
              term: {
                dob_year: year,
              },
            },
          ],
        }
      end

      it { is_expected.to eq expected }
    end
  end
end
