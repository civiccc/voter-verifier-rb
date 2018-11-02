RSpec.describe VoterVerification::Search do
  let(:query_args) { build(:search_query_args) }
  let(:max_results) { 10 }
  let(:voter_record) { build(:voter_record) }
  let(:smart_search_service) do
    described_class.new(
      query_args: query_args,
      max_results: max_results,
      smart_search: true,
    )
  end
  let(:unsmart_search_service) do
    described_class.new(
      query_args: query_args,
      max_results: max_results,
      smart_search: false,
    )
  end
  let(:mocked_results) { [voter_record] }

  before do
    allow(Queries::VoterRecord::Query).to receive(:new).and_call_original
    allow(VoterRecord).to receive(:search).
      with(an_instance_of(Elasticsearch::DSL::Search::Search)).
      and_return(mocked_results)
  end

  shared_examples 'executes a query and returns and array of VoterRecords' do |should_auto_verify|
    it 'builds a query object from the query_args and size = max_results + 1' do
      subject
      expect(Queries::VoterRecord::Query).to have_received(:new).with(
        hash_including(query_args),
      )
      expect(Queries::VoterRecord::Query).to have_received(:new).with(
        hash_including(size: max_results + 1),
      )
    end

    it { is_expected.to eq [mocked_results, should_auto_verify] }
  end

  describe '#run' do
    subject { smart_search_service.run }

    it_behaves_like 'executes a query and returns and array of VoterRecords', true

    context 'when smart_search is enabled' do
      it 'calls search with an auto query' do
        expect_any_instance_of(Queries::VoterRecord::Query).
          to receive(:auto).and_call_original
        expect(VoterRecord).to receive(:search).
          with(an_instance_of(Elasticsearch::DSL::Search::Search)).
          and_return(mocked_results)
        subject
      end

      context 'when handling multiple results' do
        let(:mocked_results) { [voter_record, build(:voter_record, score: 10)] }

        context 'when the top auto result is significantly higher than the next result' do
          let(:query_args) { build(:search_query_args) }
          let(:voter_record) { build(:voter_record, score: 35) }

          it { is_expected.to eq [mocked_results[0, 1], true] }
        end

        context 'when the top auto result has nearly the same score as the next result' do
          let(:query_args) { build(:search_query_args) }
          let(:voter_record) { build(:voter_record, score: 11) }

          it { is_expected.to eq [mocked_results, false] }
        end
      end

      context 'and results are auto-verified' do
        it 'does not call search with a top query' do
          expect_any_instance_of(Queries::VoterRecord::Query).not_to receive(:top)
          subject
        end

        it_behaves_like 'executes a query and returns and array of VoterRecords', true
      end

      context 'and results are not auto-verified' do
        let(:query_args) { build(:search_query_args, first_name: nil, middle_name: nil) }
        let(:voter_record) { build(:voter_record, first_name: nil, middle_name: nil) }

        before do
          allow(VoterRecord).to receive(:search).with(nil).and_return([])
        end

        it_behaves_like 'executes a query and returns and array of VoterRecords', false

        it 'calls search with an auto query' do
          expect_any_instance_of(Queries::VoterRecord::Query).
            to receive(:auto).and_call_original

          expect(VoterRecord).to receive(:search).with(nil).and_return([])

          subject
        end

        it 'calls search with a top query' do
          expect_any_instance_of(Queries::VoterRecord::Query).
            to receive(:top).and_call_original
          expect(VoterRecord).to receive(:search).
            with(an_instance_of(Elasticsearch::DSL::Search::Search)).
            and_return(mocked_results)

          subject
        end
      end
    end

    describe 'score grouping and filtering' do
      let(:mocked_results) do
        [15, 15, 14, 7, 7, 3].each_with_object([]) do |score, ary|
          ary << build(:voter_record, score: score)
        end
      end

      subject { unsmart_search_service.run }

      context 'when max_results is greater than the number of results' do
        let(:max_results) { 10 }
        it { is_expected.to eq [mocked_results, false] }
      end

      context 'when max_results cuts off on a group boundary' do
        let(:max_results) { 3 }
        it { is_expected.to eq [mocked_results[0, 3], false] }
      end

      context 'when max_results cuts off in the middle of a group' do
        context 'but not the first group' do
          let(:max_results) { 4 }
          it { is_expected.to eq [mocked_results[0, 3], false] }
        end

        context 'and is the first group' do
          let(:max_results) { 2 }
          it { is_expected.to eq [[], false] }
        end
      end
    end
  end
end
