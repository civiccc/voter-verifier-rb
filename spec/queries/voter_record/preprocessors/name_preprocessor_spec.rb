RSpec.describe Queries::VoterRecord::Preprocessors::Name do
  let(:first) { 'John' }
  let(:middle) { 'Jacob' }
  let(:last) { 'Jingleheimer-Schmidt' }

  subject { described_class.preprocess first, middle, last }

  describe '#preprocess' do
    let(:expected) { { first: 'John', middle: 'Jacob', last: 'Jingleheimer-Schmidt' } }

    it { is_expected.to eq(expected) }

    context 'when there is no middle name and first name has two words' do
      let(:first) { 'John Jacob' }
      let(:middle) { nil }

      it { is_expected.to eq(expected) }
    end

    context 'when there is no middle name and first name has one word' do
      let(:middle) { nil }
      let(:expected) { { first: 'John', middle: nil, last: 'Jingleheimer-Schmidt' } }

      it { is_expected.to eq(expected) }
    end

    context 'when there is a suffix' do
      let(:suffix) { 'Jr.' }
      let(:last) { "Jingleheimer-Schmidt #{suffix}" }

      it 'removes the suffix' do
        expect(subject[:last]).not_to include(suffix)
      end
    end
  end
end
