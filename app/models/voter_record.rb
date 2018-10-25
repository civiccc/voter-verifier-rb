# PORO wrapping elasticsearch results
class VoterRecord
  class ConfigError < RuntimeError; end

  def initialize(document)
    @document = document
  end

  def to_thrift
    raise NotImplementedError
  end

  class << self
    attr_accessor :client, :index, :doc_type

    def search(query)
      raise ConfigError, 'No Elasticsearch client configured' if @client.nil?

      res = client.search(index: index, type: doc_type, body: query)
      res['hits']['hits'].map { |hit| new hit['_source'] }
    end
  end
end
