RSpec.describe Queries::VoterRecord::Query do
  let(:first_name) { 'Testy' }
  let(:middle_name) { 'Quincy' }
  let(:last_name) { 'McTesterson' }
  let(:dob) { Time.new 2014, 8, 1 }
  let(:zip_code) { '94105' }
  let(:street_address) { '***REMOVED***' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }

  subject do
    described_class.new(
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      dob: dob,
      zip_code: zip_code,
      street_address: street_address,
      city: city,
      state: state,
      size: 3,
    )
  end

  describe '#auto' do
    subject { super().auto.to_hash }

    context 'when dob is nil' do
      let(:dob) { nil }

      it { is_expected.to match hash_including(min_score: described_class::MIN_SCORE_AUTO_NO_DOB) }
    end

    context 'when dob is not nil' do
      it do
        is_expected.to match hash_including(
          min_score: described_class::MIN_SCORE_AUTO_WITH_DOB,
        )
      end
    end
  end

  describe '#top' do
    subject { super().top.to_hash }

    it { is_expected.to match hash_including(min_score: described_class::MIN_SCORE_TOP) }
  end

  describe '#can_auto_verify?' do
    subject { super().send(:can_auto_verify?) }

    context 'when none of dob, zip_code, first_name and middle_name are nil' do
      it 'should return true' do
        expect(subject).to be true
      end
    end

    context 'when dob and zip_code are both nil' do
      let!(:dob) { nil }
      let!(:zip_code) { nil }

      it 'should return false' do
        expect(subject).to be false
      end
    end

    context 'when only dob is nil' do
      let!(:dob) { nil }

      it 'should return true' do
        expect(subject).to be true
      end
    end

    context 'when only zip code is nil' do
      let!(:zip_code) { nil }

      it 'should return true' do
        expect(subject).to be true
      end
    end

    context 'when first_name and middle_name are both nil' do
      let!(:first_name) { nil }
      let!(:middle_name) { nil }

      it 'should return false' do
        expect(subject).to be false
      end
    end

    context 'when only first_name is nil' do
      let!(:first_name) { nil }

      it 'should return true' do
        expect(subject).to be true
      end
    end

    context 'when only middle_name is nil' do
      let!(:middle_name) { nil }

      it 'should return true' do
        expect(subject).to be true
      end
    end
  end
end
