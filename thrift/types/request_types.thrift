namespace rb ThriftDefs.RequestTypes

include "./auth_types.thrift"
include "./geo_types.thrift"
include "./voter_record_types.thrift"

typedef string RequestId

struct Headers {
  1: optional auth_types.Entity entity,
  2: RequestId request_id,
}

struct GetVoterRecordsByIdentifiers {
  1: voter_record_types.UniqueIdentifiers voter_record_identifiers,
}

struct ContactSearch {
  1: voter_record_types.EmailAddress email ( presence = "optional", usageNote = "Must be present if email omitted. Both can be included."),
  2: voter_record_types.PhoneNumber phone ( presence = "optional", usageNote = "Must be present if email omitted. Both can be included."),
  3: i32 max_results ( presence = "optional" description = "Defaults to 100. The maximum number of results to include and consider a matches valid. This threshold can vary depending on the consumer context, but theory is that results sets that are too large indicate a lack of confidence in the match."),
}

struct RandomAddress {
  1: geo_types.StateCode state ( description = "State for which to return random addresses" ),
  2: i32 seed ( description = "Requests with the same seed will receive the same results" ),
}

struct Search {
  1: string first_name ( presence = "optional" ),
  2: string middle_name ( presence = "optional")
  3: string last_name ( presence = "required" ),
  4: voter_record_types.Date dob ( description = "Date of birth", presence="optional", usageNote="Format should be yyyy-mm-dd, but any unambiguously parseable date format will work" ),
  5: voter_record_types.EmailAddress email ( presence = "optional" ),
  6: voter_record_types.PhoneNumber phone ( presence = "optional" ),
  7: string street_address ( presence = "optional" ),
  8: string city ( presence = "optional" ),
  9: geo_types.StateCode state ( presence = "optional" ),
  10: geo_types.ZipCode zip_code ( presence = "optional" ),
  11: i32 max_results ( presence = "optional", description = "Defaults to 3. The maximum number of results to include and consider a matches valid. This threshold can vary depending on the client context, but theory is that results sets that are too large indicate a lack of confidence in the match."),
  // TODO implement exclusion
  // 12: list<voter_record_types.VoterId> exclude ( description = "A list of voter record IDs to exclude from results", presence = "optional" ),
}
