namespace rb ThriftDefs.VoterRecordTypes

include "./geo_types.thrift"

typedef string Date
typedef string DateTime
typedef string ElectionYear
typedef string EmailAddress
typedef double Percentage
typedef string PhoneNumber
typedef string VoterId
typedef map<ElectionYear, VoteType> VoteTypeMap
typedef map<ElectionYear, bool> ParticipationMap

enum VoterScore {
  UNREGISTERED = 1
  NEVER = 2
  INFREQUENT = 3
  FREQUENT = 4
  SUPER = 5
}

enum VoteType {
  ABSENTEE = 1
  EARLY = 2
  INELIGIBLE = 3
  NO_RECORD = 4
  VOTED = 5
  MAIL = 6
  AT_POLL = 7
  PROVISIONAL = 8
}

enum PhoneType {
  LANDLINE = 1
  VOIP = 2
  WIRELESS = 3
}

enum EmailMatchType {
  INDIVIDUAL = 1
  HOUSEHOLD = 2
}

enum PoliticalParty {
  CONSERVATIVE = 1
  DEMOCRAT = 2
  GREEN = 3
  INDEPENDENT = 4
  LIBERTARIAN = 5
  NO_PARTY = 6
  OTHER = 7
  REPUBLICAN = 8
  UNAFFILIATED = 9
  UNKNOWN = 10
  WORKING_FAM = 11
}

struct Scores {
  1: Percentage activist,
  2: Percentage campaign_finance,
  3: Percentage catholic,
  4: Percentage children_present,
  5: Percentage climate_change,
  6: Percentage college_funding,
  7: Percentage college_graduate,
  8: Percentage evangelical,
  9: Percentage govt_privacy,
  10: Percentage gun_control,
  11: Percentage gunowner,
  12: Percentage high_school_only,
  13: Percentage ideology,
  14: Percentage income_rank,
  15: Percentage local_voter,
  16: Percentage marriage,
  17: Percentage midterm_general_turnout,
  18: Percentage minimum_wage,
  19: Percentage moral_authority,
  20: Percentage moral_care,
  21: Percentage moral_equality,
  22: Percentage moral_equity,
  23: Percentage moral_loyalty,
  24: Percentage moral_purity,
  25: Percentage non_presidential_primary_turnout,
  26: Percentage nonchristian,
  27: Percentage offyear_general_turnout,
  28: Percentage otherchristian,
  29: Percentage paid_leave,
  30: Percentage partisan,
  31: Percentage path_to_citizen,
  32: Percentage presidential_general_turnout,
  33: Percentage presidential_primary_turnout,
  34: Percentage prochoice,
  35: Percentage tax_on_wealthy,
  36: Percentage teaparty,
  37: Percentage trump_resistance,
  38: Percentage trump_support,
  39: Percentage veteran,
  40: Percentage race_white,
  41: Percentage race_afam,
  42: Percentage race_hisp,
  43: Percentage race_natam,
  44: Percentage race_asian,
} ( description = "Numeric representations of how likely someone is to have a certain characteristic or be concerned about a given issue. These should never be exposed publicly." )

struct VoterRecord {
  1: VoterId id,
  2: string first_name,
  3: string middle_name,
  4: string last_name,
  5: Date dob ( usageNote = "This is a field with one of the lowest integrity levels. Both the month and day could be 01 in cases where the data is actually unknown." ),
  6: geo_types.Address address,
  7: geo_types.Coordinate location,
  8: ParticipationMap general_elections ( description = "For the voter registration this record corresponds to, a mapping of election years to whether someone voted in that year's general election. Only years for which this registration record applies are contained as map keys." ),
  9: PoliticalParty party ( description = "The political party to which someone is registered" ),
  11: Date registration_date,
  12: bool auto_verify ( description = "Whether the match confidence is high enough to use this record to automatically verify the user orginating the search." ),
  13: Scores scores ( description = "A container for the various alignment/idealogical scores associated with this voter record." ),
  14: VoterScore voter_score( description="A ranking indicating whether someone is e.g. unregistered or a frequent voter" )
  15: i32 num_general_election_votes,
  16: i32 num_primary_election_votes,
  17: VoteTypeMap primary_vote_types ( description = "Maps an election type and year to a string classification of someone's participation in that year's primary election" ),
  18: VoteTypeMap general_vote_types ( description = "Maps an election type and year to a string classification of someone's participation in that year's general election" ),
  19: PhoneNumber phone ( description = "Phone number, sourced from the voter file" ),
  20: PhoneNumber vb_phone ( description = "Phone number, commercially sourced" ),
  21: PhoneType vb_phone_type ( description = "The type of phone number that `phone` is, e.g. landline, VOIP, wireless" ),
  22: PhoneNumber vb_phone_wireless ( description = "Wireless phone number, commercially sourced" ),
  23: PhoneNumber ts_wireless_phone ( description = "\"Best Available\" phone number, commercially sourced" ),
  24: EmailAddress email ( description = "Email address, commercially-sourced" ),
  25: EmailMatchType email_append_level ( description = "The level at which the email address is associated with the voter record: individual or household" ),
}

struct VoterRecords {
  1: list<VoterRecord> voter_records
}

union UniqueIdentifiers {
  1: list<VoterId> ids,
}
