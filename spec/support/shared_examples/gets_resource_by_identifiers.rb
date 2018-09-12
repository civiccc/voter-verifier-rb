RSpec.shared_examples_for 'gets resource by identifiers' do
  context 'when a single, valid resource is requested' do
    let(:request) { single_valid_request }

    it 'returns the single requested resource' do
      expect(subject.public_send(field_name)).to match_array(single_valid_response)
    end
  end

  context 'when multiple resources are requested' do
    context 'and all the identifiers are valid' do
      let(:request) { multiple_valid_request }

      it 'returns all the requested resources' do
        expect(subject.public_send(field_name)).to match_array(multiple_valid_response)
      end
    end

    context 'and some of the identifiers are valid' do
      let(:request) { multiple_mixed_request }

      it 'returns only the resources that map to valid identifiers' do
        expect(subject.public_send(field_name)).to match_array(multiple_mixed_response)
      end
    end

    context 'and none of the identifiers are valid' do
      let(:request) { multiple_invalid_request }

      it 'returns an empty list' do
        expect(subject.public_send(field_name)).to match_array([])
      end
    end

    context 'and the list of identifiers is empty' do
      let(:request) { empty_request }

      it 'returns an empty list' do
        expect(subject.public_send(field_name)).to match_array([])
      end
    end

    context 'when the identifiers param is nil' do
      let(:request) { nil_request }

      it 'raises an ArgumentException' do
        expect { subject }.to raise_exception ThriftShop::Shared::ArgumentException do |e|
          expect(e).to have_attributes(
            message: 'Missing field',
            path: 'request.' + identifiers_field_name,
            code: ThriftShop::Shared::ArgumentExceptionCode::PRESENCE,
          )
        end
      end
    end
  end
end
