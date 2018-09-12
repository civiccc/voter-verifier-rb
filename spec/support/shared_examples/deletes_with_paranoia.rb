RSpec.shared_examples_for 'deletes with paranoia' do
  let(:saved_record) { create(described_class.name.underscore) }

  describe 'destroying the record' do
    subject { saved_record.destroy }

    it 'sets active to nil' do
      expect { subject }.to change {
        saved_record.active
      }.from(true).to(nil)
    end

    it 'sets deleted_at to an instance of time' do
      expect { subject }.to change {
        saved_record.deleted_at
      }.from(nil).to(an_instance_of(Time))
    end

    it 'marks the record as deleted' do
      expect { subject }.to change {
        saved_record.deleted?
      }.from(false).to(true)
    end

    context 'and then reviving the record' do
      before { subject }

      it 'marks the record as not deleted' do
        expect { saved_record.restore }.to change {
          saved_record.deleted?
        }.from(true).to(false)
      end

      it 'sets deleted_at to nil' do
        expect { saved_record.restore }.to change {
          saved_record.deleted_at
        }.from(an_instance_of(Time)).to(nil)
      end

      it 'sets active to true' do
        expect { saved_record.restore }.to change {
          saved_record.active
        }.from(nil).to(true)
      end
    end
  end
end
