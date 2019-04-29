
# ElasticSearch Index Definitions

## Types
Types in ElasticSearch can specify more than just the datatype being stored in a field. They can also specify some query semantics and configuration, notably by setting an analyzer to be used in queries on string fields. Other types have different configuration options. The index uses the following type definitions, that have been configured to strike a reasonable balance between accuracy and reach.

| Field | Type Spec |
| ----- | --------- |
| unanalyzed_string_type | `{"type": "string", "index": "not_analyzed"}` |
| name_type | `{"type": "string", "analyzer": "name_analyzer"}` |
| name_compact_type | `{"type": "string", "analyzer": "name_compact_analyzer"}`
| string_enum_type | alias for unanalyzed_string_type |
| int_type | `{"type": "integer"}` |
| float_type | `{"type": "float", "index": "no"}` |
| boolean_type | `{"type": "boolean"}` |

## Tokenizers

| Name | Type | Options |
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
