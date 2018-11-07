# Base class for a barebones (lowercase) active-record-y construct representing a document in an Elasticsearch index
class ElasticSearchDocument
  class ConfigError < RuntimeError; end

  attr_reader :score

  def initialize(document, score: nil)
    @document = document.deep_symbolize_keys!
    @score = score
  end

  def ==(other)
    id == other.id
  end

  class << self
    attr_writer :client, :index, :doc_type

    def attributes(attributes)
      attributes.each do |attr|
        define_method(attr) do
          instance_variable_get('@document')[attr]
        end
      end
    end

    def get(id)
      res = client.get(id: id, index: index, type: doc_type, ignore: 404)
      # With "ignore: 404" ES client will return false if there's no matching record, we want nil
      res ? new(res['_source']) : nil
    end

    def search(query)
      return [] if query.nil?

      res = client.search(index: index, type: doc_type, body: query)
      res['hits']['hits'].map { |hit| new(hit['_source'], score: hit['_score']) }
    end

    private

    attr_reader :index, :doc_type

    def client
      raise ConfigError, 'No Elasticsearch client configured' if @client.nil?

      @client
    end
  end
end
