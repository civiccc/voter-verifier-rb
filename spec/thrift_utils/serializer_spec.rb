RSpec.describe ThriftUtils::Thrift::Serializer do
  let(:thrift_headers) do
    ThriftDefs::RequestTypes::Headers.new(
      request_id: '1',
    )
  end

  let(:serialized_headers) do
    Thrift::Serializer.new(Thrift::BinaryProtocolFactory.new).serialize(thrift_headers)
  end

  describe '.serialize' do
    subject { described_class.serialize(thrift_headers) }

    it 'outputs a bytestring representing the binary-thrift-encoded headers' do
      expect(subject).to eq serialized_headers
    end
  end

  describe '.deserialize' do
    subject do
      described_class.deserialize(ThriftDefs::RequestTypes::Headers.new, serialized_headers)
    end

    it 'turns a binary-protocol bytestring into the expected Thrift object' do
      expect(subject).to eq thrift_headers
      expect(subject).to be_a ThriftDefs::RequestTypes::Headers
    end
  end

  describe '.to_base64' do
    subject { described_class.to_base64(thrift_headers) }

    it 'outputs a plaintext string representing the base64-binary-thrift-encoded object' do
      expect(subject).to eq Base64.strict_encode64(serialized_headers)
      expect(subject).to match %r{\A[A-Za-z0-9/+]+=*\z}
    end
  end

  describe '.from_base64' do
    let(:base64_headers) do
      Base64.strict_encode64(serialized_headers)
    end

    subject { described_class.from_base64(ThriftDefs::RequestTypes::Headers.new, base64_headers) }

    it 'turns a base64-binary bytestring into the expected thrift object' do
      expect(subject).to be_a ThriftDefs::RequestTypes::Headers
      expect(subject).to eq thrift_headers
    end
  end
end
