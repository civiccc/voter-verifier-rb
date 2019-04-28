RSpec.describe ThriftUtils::EnumConversion do
  let(:test_class) do
    klass = described_class
    Class.new do
      extend klass
    end
  end
  let(:state_code) { 'IL' }

  let(:thrift_enum) { ThriftDefs::GeoTypes::StateCode::IL }

  it 'converts from state to thrift' do
    expect(test_class.state_code_to_thrift(state_code: state_code)).
      to eq(thrift_enum)
  end

  it 'converts from thrift to state' do
    expect(test_class.thrift_to_state_code(enum: thrift_enum)).
      to eq(state_code)
  end
end
