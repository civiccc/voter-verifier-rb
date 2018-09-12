RSpec.shared_examples_for 'serializes correctly' do
  let(:serialized) { Thrift::Serializer.new.serialize(subject) }
  let(:deserialized) { Thrift::Deserializer.new.deserialize(subject.class.new, serialized) }

  it 'serializes correctly' do
    expect(deserialized).to eq subject
  end
end
