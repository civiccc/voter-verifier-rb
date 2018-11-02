FactoryBot.define do
  factory :voter_record do
    activist_score '54.3'
    address '524 THIRD ST'
    address_apt_number nil
    address_street_name 'THIRD'
    address_street_number '524'
    address_unit_designator nil
    campaign_finance_score '71.5'
    catholic_score '16.5'
    children_present_score '24.7'
    city 'SAN FRANCISCO'
    climate_change_score '72.4'
    college_funding_score '75.6'
    college_graduate_score '52.6'
    county 'SAN FRANCISCO'
    dob_day 1
    dob_month 8
    dob_year 2014
    effective_date '201012'
    email 'testy.mctesterson@example.com'
    email_append_level 'Individual'
    email_match_type nil
    email_presence_flag nil
    evangelical_score '23'
    first_name 'TESTY'
    first_name_compact 'TESTY'
    general_2000 nil
    general_2002 nil
    general_2004 nil
    general_2006 nil
    general_2008 nil
    general_2010 nil
    general_2012 true
    general_2014 true
    general_2016 true
    govt_privacy_score '66.9'
    gun_control_score '75.6'
    gunowner_score '57.4'
    high_school_only_score '16.4'
    id 'CA-1234567'
    ideology_score '60.3'
    income_rank_score '85'
    last_name 'MCTESTERSON'
    last_name_compact 'MCTESTERSON'
    lat_lng_location '35.1868,-106.6652'
    local_voter_score '22'
    marriage_score '93.8'
    middle_name 'QUINCY'
    middle_name_compact 'QUINCY'
    midterm_general_turnout_score '88.2'
    minimum_wage_score '72.8'
    moral_authority_score '47.7'
    moral_care_score '52.6'
    moral_equality_score '39.1'
    moral_equity_score '57.8'
    moral_loyalty_score '49.2'
    moral_purity_score '24.7'
    non_presidential_primary_turnout_score '73.9'
    nonchristian_score '27.3'
    num_general_election_votes 3
    num_primary_election_votes 2
    offyear_general_turnout_score '30.8'
    otherchristian_score '33.2'
    paid_leave_score '66.6'
    partisan_score '98.4'
    party 'Democrat'
    path_to_citizen_score '60.6'
    phone '1234567890'
    presidential_general_turnout_score '86.7'
    presidential_primary_turnout_score '81.3'
    prochoice_score '67.4'
    race_afam_score '1.60719258447262e-002'
    race_asian_score '7.94480871607957e-003'
    race_hisp_score '1.47680410083167e-002'
    race_natam_score '9.11542062835216e-003'
    race_white_score '0.952099803802525'
    registration_date '2012/08/17'
    st 'CA'
    status_flag 'A'
    suffix nil
    tax_on_wealthy_score '72.4'
    teaparty_score '11.9'
    trump_resistance_score '56.9'
    trump_support_score '11.4'
    ts_address '524 THIRD STREET'
    ts_address_apt_number '1'
    ts_address_street_name 'THIRD'
    ts_address_street_number '524'
    ts_address_unit_designator 'SUITE'
    ts_city 'SAN FRANCISCO'
    ts_exact_track 'Y12345678901234'
    ts_lat_lng_location '35.1868,-106.6652'
    ts_st 'NM'
    ts_wireless_phone '1234567892'
    ts_zip_code '94105'
    urbanicity_rank 42
    vb_phone '1234567891'
    vb_phone_type 'WIRELESS'
    vb_phone_wireless '1234567893'
    veteran_score '44'
    vf_g2012 'E'
    vf_g2014 'Y'
    vf_g2016 'A'
    vf_p2012 nil
    vf_p2014 'N'
    vf_p2016 'I'
    voter_score 'Frequent Voter'
    zip_code '94105'

    score 10

    initialize_with { new(attributes.except(:score), score: attributes[:score]) }
  end
end
