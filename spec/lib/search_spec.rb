RSpec.describe VoterVerification::Search do
  let(:query_args) { build(:search_query_args) }
  let(:voter_record) { build(:voter_record) }
  let(:smart_search_service) { described_class.new(query_args, smart_search: true) }
  let(:unsmart_search_service) { described_class.new(query_args, smart_search: false) }

  before do
    allow(Queries::VoterRecord::Query).to receive(:new).and_call_original
    allow(VoterRecord).to receive(:search).
      with(an_instance_of(Elasticsearch::DSL::Search::Search), any_args).
      and_return([voter_record])
  end

  shared_examples 'executes a query and returns and array of VoterRecords' do
    it 'builds a query object from the query_args' do
      subject
      expect(Queries::VoterRecord::Query).to have_received(:new).with(query_args)
    end

    it { is_expected.to(match(all(an_instance_of(VoterRecord)))) }
  end

  describe '#run' do
    subject { smart_search_service.run }

    it_behaves_like 'executes a query and returns and array of VoterRecords'

    context 'when smart_search is enabled' do
      it 'calls search with an auto query' do
        expect_any_instance_of(Queries::VoterRecord::Query).
          to receive(:auto).and_call_original
        expect(VoterRecord).to receive(:search).
          with(an_instance_of(Elasticsearch::DSL::Search::Search), auto_verify_results: true).
          and_return([voter_record])
        subject
      end

      context 'and results are auto-verified' do
        before do
          allow(VoterRecord).to receive(:search).
            with(an_instance_of(Elasticsearch::DSL::Search::Search), any_args).
            and_return([voter_record])
        end

        it 'does not call search with a top query' do
          expect_any_instance_of(Queries::VoterRecord::Query).not_to receive(:top)
          subject
        end

        it_behaves_like 'executes a query and returns and array of VoterRecords'
      end

      context 'and results are not auto-verified' do
        let(:query_args) { build(:search_query_args, first_name: nil, middle_name: nil) }
        let(:voter_record) { build(:voter_record, first_name: nil, middle_name: nil) }

        before do
          allow(VoterRecord).to receive(:search).
            with(anything, auto_verify_results: true).
            and_return([])

          allow(VoterRecord).to receive(:search).
            with(an_instance_of(Elasticsearch::DSL::Search::Search)).
            and_return([voter_record])
        end

        it_behaves_like 'executes a query and returns and array of VoterRecords'

        it 'calls search with an auto query' do
          expect_any_instance_of(Queries::VoterRecord::Query).
            to receive(:auto).and_call_original

          expect(VoterRecord).to receive(:search).
            with(anything, auto_verify_results: true).
            and_return([])

          subject
        end

        it 'calls search with a top query' do
          expect_any_instance_of(Queries::VoterRecord::Query).
            to receive(:top).and_call_original
          expect(VoterRecord).to receive(:search).
            with(an_instance_of(Elasticsearch::DSL::Search::Search)).
            and_return([voter_record])

          subject
        end
      end
    end

    context 'when smart_search is disabled' do
      subject { unsmart_search_service.search }
    end
  end
end
