require 'elasticsearch/dsl'

# Query builders for searching the voter record index in ElasticSearch
module Queries
  module DSL
    include Elasticsearch::DSL
  end
end
