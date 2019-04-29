
# ElasticSearch Index Definitions

## Fields

### Definitions
These are the fields defined on the index. The full ElasticSearch options for each field spec are in the [table below](#field-specs).
| id | unanalyzed_string_type |
| first_name | name_type |
| first_name_compact | name_compact_type |
| middle_name | name_type |
| middle_name_compact | name_compact_type |
| last_name | name_type |
| last_name_compact | name_compact_type |
| suffix | name_type |
| dob_year | int_type |
| dob_month | int_type |
| dob_day | int_type |
| registration_date | unanalyzed_string_type |
| address | address_type |
| city | analyzed_string_type |
| st | unanalyzed_string_type |
| zip_code | unanalyzed_string_type |
| lat_lng_location | geo_point_type |
| county | unanalyzed_string_type |
| address_street_name | unanalyzed_string_type |
| address_street_number | unanalyzed_string_type |
| address_unit_designator | unanalyzed_string_type |
| address_apt_number | unanalyzed_string_type |
| ts_address | address_type |
| ts_city | unanalyzed_string_type |
| ts_st | unanalyzed_string_type |
| ts_zip_code | unanalyzed_string_type |
| ts_lat_lng_location | geo_point_type |
| ts_address_street_name | unanalyzed_string_type |
| ts_address_street_number | unanalyzed_string_type |
| ts_address_unit_designator | unanalyzed_string_type |
| ts_address_apt_number | unanalyzed_string_type |
| party | unanalyzed_string_type |
| email | unanalyzed_string_type |
| general_2016 | boolean_type |
| general_2014 | boolean_type |
| general_2012 | boolean_type |
| general_2010 | boolean_type |
| general_2008 | boolean_type |
| general_2006 | boolean_type |
| general_2004 | boolean_type |
| general_2002 | boolean_type |
| general_2000 | boolean_type |
| vf_g2016 | string_enum_type |
| vf_g2014 | string_enum_type |
| vf_g2012 | string_enum_type |
| vf_p2016 | string_enum_type |
| vf_p2014 | string_enum_type |
| vf_p2012 | string_enum_type |
| voter_score | string_enum_type |
| num_general_election_votes | int_type |
| num_primary_election_votes | int_type |
| activist_score | float_type |
| campaign_finance_score | float_type |
| catholic_raw_score | float_type |
| children_present_score | float_type |
| climate_change_score | float_type |
| college_funding_score | float_type |
| college_graduate_score | float_type |
| evangelical_raw_score | float_type |
| govt_privacy_score | float_type |
| gun_control_score | float_type |
| gunowner_score | float_type |
| high_school_only_score | float_type |
| ideology_score | float_type |
| income_rank_score | float_type |
| local_voter_score | float_type |
| marriage_score | float_type |
| midterm_general_turnout_score | float_type |
| minimum_wage_score | float_type |
| moral_authority_score | float_type |
| moral_care_score | float_type |
| moral_equality_score | float_type |
| moral_equity_score | float_type |
| moral_loyalty_score | float_type |
| moral_purity_score | float_type |
| non_presidential_primary_turnout_score | float_type |
| nonchristian_raw_score | float_type |
| offyear_general_turnout_score | float_type |
| otherchristian_raw_score | float_type |
| paid_leave_score | float_type |
| partisan_score | float_type |
| path_to_citizen_score | float_type |
| presidential_general_turnout_score | float_type |
| presidential_primary_turnout_score | float_type |
| prochoice_score | float_type |
| tax_on_wealthy_score | float_type |
| teaparty_score | float_type |
| trump_resistance_score | float_type |
| trump_support_score | float_type |
| veteran_score | float_type |
| race_white_score | float_type |
| race_afam_score | float_type |
| race_hisp_score | float_type |
| race_natam_score | float_type |
| race_asian_score | float_type |

### Field Specs
The index uses the following field specs, which have been configured to strike a reasonable balance between accuracy and reach.

| Name | Options |
| ---- | --------- |
| unanalyzed_string_type | `{"type": "string", "index": "not_analyzed"}` |
| analyzed_string_type | `{"type": "string", "analyzer": "simple"}` |
| address_type | `{"type": "string", "analyzer": "address_analyzer"}` |
| name_type | `{"type": "string", "analyzer": "name_analyzer"}` |
| name_compact_type | `{"type": "string", "analyzer": "name_compact_analyzer"}`
| string_enum_type | alias for unanalyzed_string_type |
| int_type | `{"type": "integer"}` |
| float_type | `{"type": "float", "index": "no"}` |
| boolean_type | `{"type": "boolean"}` |
| geo_point_type | `{"type": "geo_point", "fielddata" : {"format" : "compressed", "precision" : "3m"} }` |

> Note: adjusting the precision level on geo_point_type has a significant effect on both index size and query performance.ß

## Tokenizers

| Name | Type | Options |
| ---- | ---- | ------- |
| address_tokenizer | pattern | `"pattern": "[^a-zA-Z0-9]+"` |
| name_tokenizer | pattern | `"pattern": "[^a-zA-Z0-9']+"` |

## Analyzers

| Name | Type | Tokenizer | Filter |
| ---- | ---- | --------- | ------ |
| address_analyzer | custom | address_tokenizer | lowercase, address_synonym |
| name_analyzer | custom | name_tokenizer | lowercase |
| name_compact_analyzer | custom | keyword | lowercase, alphanumeric |
| first_name_analyzer | custom | name_tokenizer | lowercase, first_name_synonym |

## Filters

| Name | Type | Options |
| ---- | ---- | ------- |
| address_synonym | synonym | `"synonyms": address_synonyms, "expand": false` |
| first_name_synonym | synonym | `"synonyms": first_name_synonyms, "expand": true`
| alphanumeric | pattern_replace | `"pattern": "[^a-zA-Z0-9]", "replacement": ""`

## Synonyms
| Name | Source |
| ---- | ------ |
| address_synonyms | [data/address_synonyms.txt](./data/address_synonyms.txt) |
| first_name_synonyms | [data/first_name_synonyms.txt](./data/first_name_synonyms.txt) |
