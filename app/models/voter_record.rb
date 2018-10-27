require 'service_utilities'

# PORO wrapping elasticsearch results
class VoterRecord
  include EnumConversion

  class ConfigError < RuntimeError; end

  POLITICAL_PARTY_TO_THRIFT = ThriftShop::Verification::PoliticalParty::VALUE_MAP.invert.
    transform_keys(&:titleize).freeze

  EMAIL_APPEND_LEVEL_TO_THRIFT = ThriftShop::Verification::EmailMatchType::VALUE_MAP.invert.
    transform_keys(&:titleize).freeze

  VOTER_SCORE_THRIFT_KEY_TO_TS = {
    'FREQUENT' => 'Frequent Voter',
    'INFREQUENT' => 'Infrequent Voter',
    'NEVER' => 'Never Voted',
    'SUPER' => 'Super Voter',
    'UNREGISTERED' => 'Unregistered',
  }.transform_values(&:freeze).freeze

  VOTER_SCORE_TO_THRIFT = ThriftShop::Verification::VoterScore::VALUE_MAP.invert.
    transform_keys { |key| VOTER_SCORE_THRIFT_KEY_TO_TS[key] }.freeze

  VOTE_TYPE_THRIFT_KEY_TO_TS = {
    'ABSENTEE' => 'A',
    'EARLY' => 'E',
    'INELIGIBLE' => 'I',
    'NO_RECORD' => 'N',
    'VOTED' => 'Y',
  }.transform_values(&:freeze).freeze

  VOTE_TYPE_TO_THRIFT = ThriftShop::Verification::VoteType::VALUE_MAP.invert.
    transform_keys { |key| VOTE_TYPE_THRIFT_KEY_TO_TS[key] }.freeze

  PHONE_TYPE_TYPE_TO_THRIFT = ThriftShop::Verification::PhoneType::VALUE_MAP.invert.freeze

  RACE_SCORES = Set.new(
    %w[
      race_afam
      race_asian
      race_hisp
      race_natam
      race_white
    ],
  )

  def initialize(document)
    @document = document.deep_symbolize_keys!
  end

  def method_missing(name, *args)
    return @document[name] if @document.include?(name)

    super
  end

  def respond_to_missing?(name, *args)
    @document.include?(name) || super
  end

  def to_thrift
    ThriftShop::Verification::VoterRecord.new(
      id: id,
      exact_track: ts_exact_track,
      first_name: first_name,
      middle_name: middle_name,
      last_name: last_name,
      dob: dob,
      address: thrift_address,
      location: thrift_location,
      party: POLITICAL_PARTY_TO_THRIFT[party],
      registration_date: Date.parse(registration_date).iso8601,
      email: email,
      email_append_level: EMAIL_APPEND_LEVEL_TO_THRIFT[email_append_level],
      voter_score: VOTER_SCORE_TO_THRIFT[voter_score],
      num_general_election_votes: num_general_election_votes,
      num_primary_election_votes: num_primary_election_votes,
      phone: phone,
      vb_phone: vb_phone,
      ts_wireless_phone: ts_wireless_phone,
      vb_phone_wireless: vb_phone_wireless,
      vb_phone_type: PHONE_TYPE_TYPE_TO_THRIFT[vb_phone_type],
      general_elections: thrift_general_elections,
      general_vote_types: thrift_general_vote_types,
      primary_vote_types: thrift_primary_vote_types,
      scores: thrift_scores,
    )
  end

  def dob
    '%<year>04i-%<month>02i-%<day>02i'.%(
      year: dob_year || 0,
      month: dob_month || 0,
      day: dob_day || 0,
    )
  end

  private

  def ts_address_field(field_name)
    send(field_name) || send("ts_#{field_name}")
  end

  def thrift_address
    ThriftShop::Verification::Address.new(
      street: ts_address_field(:address),
      apt_number: ts_address_field(:address_apt_number),
      street_name: ts_address_field(:address_street_name),
      street_number: ts_address_field(:address_street_number),
      unit_designator: ts_address_field(:address_unit_designator),
      city: ts_address_field(:city),
      state: state_code_to_thrift(state_code: ts_address_field(:st)),
      zip_code: ts_address_field(:zip_code),
    )
  end

  def thrift_scores
    extract_and_transform_keys_matching(/_score$/) do |key, value|
      (RACE_SCORES.include?(key) ? value.to_f * 100 : value.to_f).round(1)
    end.except('voter')
  end

  def thrift_location
    return if lat_lng_location.nil?

    lat, lng = lat_lng_location.split(',')
    ThriftShop::Verification::GeoCoordinate.new(lat: lat, lng: lng)
  end

  def thrift_general_elections
    extract_and_transform_keys_matching(/^general_/)
  end

  def thrift_primary_vote_types
    extract_and_transform_keys_matching(/^vf_p/) { |_, value| VOTE_TYPE_TO_THRIFT[value] }
  end

  def thrift_general_vote_types
    extract_and_transform_keys_matching(/^vf_g/) { |_, value| VOTE_TYPE_TO_THRIFT[value] }
  end

  def extract_and_transform_keys_matching(pattern, keep_nil_values: false)
    @document.each_with_object({}) do |(key, value), hash|
      next unless keep_nil_values || !value.nil?
      next unless pattern.match(str_key = key.to_s)

      stripped_key = str_key.gsub(pattern, '')
      hash[stripped_key] = block_given? ? yield(stripped_key, value) : value
    end
  end

  class << self
    attr_writer :client, :index, :doc_type

    def get(id)
      res = client.get(id: id, index: index, type: doc_type, ignore: 404)
      # With "ignore: 404" ES client will return false if there's no matching record, we want nil
      res ? new(res['_source']) : nil
    end

    def search(query)
      res = client.search(index: index, type: doc_type, body: query)
      res['hits']['hits'].map { |hit| new hit['_source'] }
    end

    private

    attr_reader :index, :doc_type

    def client
      raise ConfigError, 'No Elasticsearch client configured' if @client.nil?

      @client
    end
  end
end
