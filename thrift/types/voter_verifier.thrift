namespace rb ThriftDefs.VoterVerifier

include "./exception_types.thrift"
include "./geo_types.thrift"
include "./request_types.thrift"
include "./voter_record_types.thrift"

typedef geo_types.Addresses RandomAddresses

service Service {
  voter_record_types.VoterRecords get_voter_records_by_identifiers(
    1: request_types.Headers headers,
    2: request_types.GetVoterRecordsByIdentifiers request,
  ) throws (
    1: exception_types.ArgumentException argument_exception,
    2: exception_types.UnauthorizedException unauthorized_exception,
  ) ( description = "Fetch a set of voter records by ID" )

  voter_record_types.VoterRecords search(
    1: request_types.Headers headers,
    2: request_types.Search request,
  ) throws (
    1: exception_types.ArgumentException argument_exception,
    2: exception_types.StateException state_exception ( description = "Thrown if the search attempt limit has been reached" ),
    3: exception_types.UnauthorizedException unauthorized_exception,
  ) ( description = "Search for voter records, applying matching criteria based on the data provided in the search request" )

  voter_record_types.VoterRecords contact_search(
    1: request_types.Headers headers,
    2: request_types.ContactSearch request,
  ) throws (
    1: exception_types.ArgumentException argument_exception,
    2: exception_types.UnauthorizedException unauthorized_exception,
  ) ( description = "More permissive search" )

  RandomAddresses get_random_addresses(
    1: request_types.Headers headers,
    2: request_types.RandomAddress request,
  ) throws (
    1: exception_types.ArgumentException argument_exception,
    2: exception_types.UnauthorizedException unauthorized_exception,
  ) ( description = "Get random addresses used to get up to a minimum number of choices to present to a user" )
}
