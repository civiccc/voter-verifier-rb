require 'elasticsearch/transport'

VoterRecord.client = Elasticsearch::Client.new(
  hosts: configatron.elasticsearch.hosts,
  timeout: configatron.elasticsearch.timeout,
  retry_on_failure: configatron.elasticsearch.retries,
)
VoterRecord.index = configatron.elasticsearch.voter_record_index
VoterRecord.doc_type = configatron.elasticsearch.voter_record_doc_type
