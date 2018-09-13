RSpec.describe VoterRecord do
  subject(:voter_record) { build(:voter_record) }

  describe '#to_thrift' do
    it { should respond_to(:to_thrift) }
  end
end
