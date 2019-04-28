RSpec.describe ThriftUtils::Validation do
  let(:role) { nil }
  let(:headers) do
    ThriftDefs::RequestTypes::Headers.new(
      entity: ThriftDefs::AuthTypes::Entity.new(
        uuid: headers_entity_uuid,
        role: role,
      ),
    )
  end
  let(:headers_entity_uuid) { '12345678-1234-1234-1234-123456781234' }
  let(:request) do
    ThriftDefs::RequestTypes::RandomAddress.new(
      state: ThriftDefs::GeoTypes::StateCode::CA,
    )
  end

  let(:handler) do
    klass = described_class
    Class.new(ThriftServer::ThriftHandler) do
      include klass
    end.new(headers, request)
  end

  describe '#verify_field_presence' do
    subject { handler.verify_field_presence(field: field) }

    context 'when the field does not exist' do
      let(:field) { 'seed' }

      it 'should raise an ArgumentException' do
        expect { subject }.to raise_exception(ThriftDefs::ExceptionTypes::ArgumentException) do |e|
          expect(e).to have_attributes(
            message: 'Missing field',
            path: "request.#{field}",
            code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::PRESENCE,
          )
        end
      end
    end

    context 'when the field does exist' do
      let(:field) { 'state' }

      it 'should not raise an exception' do
        expect { subject }.not_to raise_exception
      end
    end
  end

  describe '#verify_date_time_field_format' do
    subject { handler.verify_date_time_field_format(field: :dob) }

    let(:request) do
      ThriftDefs::RequestTypes::Search.new(
        dob: date_time_value
      )
    end

    context 'when the field is in iso8601 format' do
      let(:date_time_value) { Time.now.iso8601 }

      it 'should not raise an error' do
        expect { subject }.not_to raise_exception
      end
    end

    context 'when the field is some nonsense string' do
      let(:date_time_value) { 'I am not a date' }

      it 'should raise an ArgumentException' do
        expect { subject }.to raise_exception(ThriftDefs::ExceptionTypes::ArgumentException) do |e|
          expect(e).to have_attributes(
            message: 'dob was not a valid Date or DateTime',
            path: 'request.dob',
            code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::INVALID,
          )
        end
      end
    end
  end
end
