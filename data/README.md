# Voter Record Data Fields
Voter Verifier is offered "batteries not included," meaning the raw data from voter records necessary to make it useful is not included. But if you already have voter record data, this is what general data points Voter Verifier assumes to exist in an ElasticSearch index. They are divided into groups below and explained in more detail. Some groups are used in the matching process, and some are only returned in results.

| Group | Used in Matching? |
| ----- | ----------------- |
| Identifier | No |
| Name | Yes |
| Date of Birth | Yes |
| Address | Yes |
| Contact Info | Yes |
| Voter Details | No |
| Issue and Characteristic Scores | No |

These are the fields and their types (yes...ElasticSearch does have types) that comprise the voter
record index.

## Identifier
A stable identifier for the record. This may not, and frequently will not, map 1:1 to people.

| Field | Type | Notes |
| ----- | ---- | ----- |
| id | string | |

## Name
There are two fields for each name component (except suffix) because it's useful to use two different sets of tokenizers and analyzers when looking for name matches to account for a lot of different weird things with names: McDonald vs Mc Donald, O'Rourke vs O Rourke vs O' Rourke for example. The same raw value is stored in each field, but the fields use different types (with different tokenizers and analyzers applied to them).

| Field | Type | Notes |
| ----- | ---- | ----- |
| first_name| string |  |
| first_name_compact | string | |
| middle_name | string | |
| middle_name_compact | string | |
| last_name | string | |
| last_name_compact | string | |
| suffix | string | |

## Date of Birth
Date of birth is stored as three separate fields and as ints to be able to do range and arithmetic queries.

| Field | Type | Notes |
| ----- | ---- | ----- |
| dob_year | int | |
| dob_month | int | |
| dob_day | int | |

## Address
There are two sets of address fields for a given record. The first is the registered address per the voter record. The registered address on the voter file and the current address (that most users would enter in a search) are frequently different. Fields prefixed with `ts_` are for a best-guess-actual-address (usually commercially sourced). The query logic takes both addresses into account when ranking matches.

| Field | Type | Notes |
| ----- | ---- | ----- |
| address | string | full (unparsed) street address |
| city  | string | |
| st | string | two-letter state code (insert Gary Gulman clip here) |
| zip_code | string | either zip-5 of zip+4 is fine, only zip-5 is used |
| lat_lng_location | geo_point | derived from the zip code, a comma-separated pair of lat,lng |
| address_street_name | string | "Main St" of "000 Main St, Apt 4" |
| address_street_number | string | "000" of "000 Main St, Apt 4" |
| address_unit_designator | string | "Apt" of "000 Main St, Apt 4" |
| address_apt_number | string | "4" of "000 Main St, Apt 4" |
| ts_address | string | |
| ts_city | string | |
| ts_st | string | |
| ts_zip_code | string | |
| ts_lat_lng_location | geo_point | this is derived from geocoding the zip code like above |
| ts_address_street_name | string | |
| ts_address_street_number | string | |
| ts_address_unit_designator | string | |
| ts_address_apt_number | string | |

## Contact Info
Similar to an address, phone numbers have multiple fields. The current index allows for 4 (potentially but not necessarily) distinct phone number fields on a given record, two of which are specifically intended to be a cell phone number, which is what most end users would provide in a search.

| Field | Type | Notes |
| ----- | ---- | ----- |
| phone | string | Registered on the actual voter record |
| vb_phone | string | Best guess current phone |
| vb_phone_type | string | Type of phone that the best guess is. see thrift defs for an enum of expected values. |
| vb_phone_wireless | string | Best guess cell phone |
| ts_wireless_phone | string | Alternate best guess cell phone |
| email | string | |
| email_append_level | string | See thrift defs for an enum of expected values. |

## Voter Details
These fields are not used in searching, but are returned with the results.

| Field | Type | Notes |
| ----- | ---- | ----- |
| registration_date | string | any valid date format |
| party | string_enum | Political party affiliation. See the thrift defs for an enum of expected values. |
| voter_score | string_enum | A categorization of someone's frequency of voting. |
| general_YYYY | bool | a boolean flag indicating whether someone participated in the general election in year YYYY any number of years may be added as fields (see updating the index for a discussion of what changes to the index mean for the application code). |
| vf_gYYYY | string_enum | a categorization of someone's vote type (e.g. early, absentee, etc) in the (g)eneral election of year YYYY. Any number of such fields may be added for different years. |
| vf_pYYYY | string_enum | a categorization of someone's vote type (e.g. early, absentee, etc) in the (p)rimary of year YYYY. Any number of such fields may be added for different years. |
| num_general_election_votes | int | |
| num_primary_election_votes | int | |

## Issue and Characteristic Scores
Scores indicating propensities for various issues and likelihood of having various characteristics. All are floats for percentages (e.g. a value of 95.2 -> 95.2%) except where noted. These fields are not used in searching, but are returned with the results.

| Field | Type | Notes |
| ----- | ---- | ----- |
| activist_score | float | |
| campaign_finance_score | float | |
| catholic_score | float | |
| children_present_score | float | |
| climate_change_score | float | |
| college_funding_score | float | |
| college_graduate_score | float | |
| evangelical_score | float | |
| govt_privacy_score | float | |
| gun_control_score | float | |
| gunowner_score | float | |
| high_school_only_score | float | |
| ideology_score | float | |
| income_rank_score | float | |
| local_voter_score | float | |
| marriage_score | float | |
| midterm_general_turnout_score | float | |
| minimum_wage_score | float | |
| moral_authority_score | float | |
| moral_care_score | float | |
| moral_equality_score | float | |
| moral_equity_score | float | |
| moral_loyalty_score | float | |
| moral_purity_score | float | |
| non_presidential_primary_turnout_score | float | |
| nonchristian_score | float | |
| offyear_general_turnout_score | float | |
| otherchristian_score | float | |
| paid_leave_score | float | |
| partisan_score | float | |
| path_to_citizen_score | float | |
| presidential_general_turnout_score | float | |
| presidential_primary_turnout_score | float | |
| prochoice_score | float | |
| tax_on_wealthy_score | float | |
| teaparty_score | float | |
| trump_resistance_score | float | |
| trump_support_score | float | |
| veteran_score | float | |
| race_white_score | float | Decimals instead of percentages (e.g. 0.952 -> 95.2%) |
| race_afam_score | float | Decimals instead of percentages (e.g. 0.952 -> 95.2%) |
| race_hisp_score | float | Decimals instead of percentages (e.g. 0.952 -> 95.2%) |
| race_natam_score | float | Decimals instead of percentages (e.g. 0.952 -> 95.2%) |
| race_asian_score | float | Decimals instead of percentages (e.g. 0.952 -> 95.2%) |
