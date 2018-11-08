require 'service_utilities'

# PORO wrapping elasticsearch results
class VoterRecord < ElasticSearchDocument
  attributes %i[
    activist_score
    address
    address_apt_number
    address_street_name
    address_street_number
    address_unit_designator
    campaign_finance_score
    catholic_score
    children_present_score
    city
    climate_change_score
    college_funding_score
    college_graduate_score
    county
    dob_day
    dob_month
    dob_year
    effective_date
    email
    email_append_level
    email_match_type
    email_presence_flag
    evangelical_score
    first_name
    first_name_compact
    general_2000
    general_2002
    general_2004
    general_2006
    general_2008
    general_2010
    general_2012
    general_2014
    general_2016
    govt_privacy_score
    gun_control_score
    gunowner_score
    high_school_only_score
    id
    ideology_score
    income_rank_score
    last_name
    last_name_compact
    lat_lng_location
    local_voter_score
    marriage_score
    middle_name
    middle_name_compact
    midterm_general_turnout_score
    minimum_wage_score
    moral_authority_score
    moral_care_score
    moral_equality_score
    moral_equity_score
    moral_loyalty_score
    moral_purity_score
    non_presidential_primary_turnout_score
    nonchristian_score
    num_general_election_votes
    num_primary_election_votes
    offyear_general_turnout_score
    otherchristian_score
    paid_leave_score
    partisan_score
    party
    path_to_citizen_score
    phone
    presidential_general_turnout_score
    presidential_primary_turnout_score
    prochoice_score
    race_afam_score
    race_asian_score
    race_hisp_score
    race_natam_score
    race_white_score
    registration_date
    st
    status_flag
    suffix
    tax_on_wealthy_score
    teaparty_score
    trump_resistance_score
    trump_support_score
    ts_address
    ts_address_apt_number
    ts_address_street_name
    ts_address_street_number
    ts_address_unit_designator
    ts_city
    ts_exact_track
    ts_lat_lng_location
    ts_st
    ts_wireless_phone
    ts_zip_code
    urbanicity_rank
    vb_phone
    vb_phone_type
    vb_phone_wireless
    veteran_score
    vf_g2012
    vf_g2014
    vf_g2016
    vf_p2012
    vf_p2014
    vf_p2016
    voter_score
    zip_code
  ]

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

  VOTE_TYPE_TO_THRIFT = {
    'A' => ThriftShop::Verification::VoteType::ABSENTEE,
    'B' => ThriftShop::Verification::VoteType::ABSENTEE,
    'E' => ThriftShop::Verification::VoteType::EARLY,
    'F' => ThriftShop::Verification::VoteType::EARLY,
    'I' => ThriftShop::Verification::VoteType::INELIGIBLE,
    'M' => ThriftShop::Verification::VoteType::MAIL,
    'N' => ThriftShop::Verification::VoteType::NO_RECORD,
    'P' => ThriftShop::Verification::VoteType::AT_POLL,
    'Q' => ThriftShop::Verification::VoteType::PROVISIONAL,
    'R' => ThriftShop::Verification::VoteType::AT_POLL,
    'S' => ThriftShop::Verification::VoteType::PROVISIONAL,
    'Y' => ThriftShop::Verification::VoteType::VOTED,
    'Z' => ThriftShop::Verification::VoteType::VOTED,
  }.freeze

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

  def to_thrift
    begin
      parsed_registration_date = Date.parse(registration_date)
    # TypeError when request.dob is nil, ArgumentError when it's invalid as a date
    rescue TypeError, ArgumentError
      parsed_registration_date = nil
    end

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
      registration_date: parsed_registration_date&.iso8601,
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

  def thrift_address
    VoterRecordAddress.new(@document).to_thrift
  end

  def thrift_scores
    score_attrs = extract_and_transform_keys_matching(/_score$/) do |key, value|
      (RACE_SCORES.include?(key) ? value.to_f * 100 : value.to_f).round(1)
    end

    ThriftShop::Verification::Scores.new(**score_attrs.except('voter').symbolize_keys)
  end

  def thrift_location
    return if lat_lng_location.nil?

    lat, lng = lat_lng_location.split(',')
    ThriftShop::Verification::GeoCoordinate.new(lat: lat.to_f, lng: lng.to_f)
  end

  def thrift_general_elections
    extract_and_transform_keys_matching(/^general_/)
  end

  def thrift_primary_vote_types
    extract_and_transform_keys_matching(/^vf_p/) { |_key, value| VOTE_TYPE_TO_THRIFT[value] }
  end

  def thrift_general_vote_types
    extract_and_transform_keys_matching(/^vf_g/) do |_key, value|
      VOTE_TYPE_TO_THRIFT[value]
    end
  end

  def extract_and_transform_keys_matching(pattern, keep_nil_values: false)
    @document.each_with_object({}) do |(key, value), hash|
      next unless keep_nil_values || !value.nil?
      next unless pattern.match(str_key = key.to_s)

      stripped_key = str_key.gsub(pattern, '')
      hash[stripped_key] = block_given? ? yield(stripped_key, value) : value
    end
  end
end
