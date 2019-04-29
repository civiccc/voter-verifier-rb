require 'elasticsearch/transport'

client = Elasticsearch::Client.new(
  hosts: configatron.elasticsearch.hosts,
  timeout: configatron.elasticsearch.timeout,
  retry_on_failure: configatron.elasticsearch.retries,
)

# TODO DRY this up, which probably means either better developing the ODM/Document system or using an ODM gem
VoterRecord.client = client
VoterRecord.index = configatron.elasticsearch.voter_record_index
VoterRecord.doc_type = configatron.elasticsearch.voter_record_doc_type

VoterRecordAddress.client = client
VoterRecordAddress.index = configatron.elasticsearch.voter_record_index
VoterRecordAddress.doc_type = configatron.elasticsearch.voter_record_doc_type
