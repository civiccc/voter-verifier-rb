RSpec.shared_examples_for 'paginates correctly' do |model, response_field|
  context 'when pagination_params are provided' do
    let(:pagination_params) do
      ThriftShop::Shared::BoundaryLimitPaginationParams.new(
        direction: ThriftShop::Shared::BoundaryLimitPaginationDirection::AFTER,
        limit: limit,
        boundary_uid: nil,
      )
    end

    context 'and the limit is higher than the full set of objects' do
      let(:limit) { model.count + 1 }

      it 'returns all of them' do
        expect(subject.public_send(response_field)).to match_array(
          model.all.map(&:to_thrift),
        )
      end
    end

    context 'and the limit is lower than the full set of objects' do
      let(:limit) { model.count - 1 }

      it 'does not return the full set' do
        expect(subject.public_send(response_field)).not_to match_array(
          model.all.map(&:to_thrift),
        )
      end

      it 'contains a subset of a number defined by the limit' do
        expect(subject.public_send(response_field).count).to eq(limit)
      end

      it 'has page info' do
        expect(subject.page_info).to have_attributes(
          has_before: false,
          has_after: true,
          total_count: model.count,
        )
      end
    end

    context 'and the limit is missing' do
      let(:limit) { nil }

      it 'raises an exception' do
        expect { subject }.to raise_exception ThriftShop::Shared::ArgumentException do |e|
          expect(e).to have_attributes(
            message: 'Missing field',
            path: 'request.pagination_params.limit',
            code: ThriftShop::Shared::ArgumentExceptionCode::PRESENCE,
          )
        end
      end
    end
  end

  context 'when the pagination_params are missing' do
    let(:pagination_params) { nil }

    it 'raises an exception' do
      expect { subject }.to raise_exception ThriftShop::Shared::ArgumentException do |e|
        expect(e).to have_attributes(
          message: 'Missing field',
          path: 'request.pagination_params',
          code: ThriftShop::Shared::ArgumentExceptionCode::PRESENCE,
        )
      end
    end
  end
end
