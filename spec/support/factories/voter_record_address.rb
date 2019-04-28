FactoryBot.define do
  factory :voter_record_address do
    address '000 Third ST'
    address_apt_number nil
    address_street_name 'THIRD'
    address_street_number '000'
    address_unit_designator nil
    city 'SAN FRANCISCO'
    st 'CA'
    ts_address '000 Third STREET'
    ts_address_apt_number '1'
    ts_address_street_name 'THIRD'
    ts_address_street_number '000'
    ts_address_unit_designator 'SUITE'
    ts_city 'SAN FRANCISCO'
    ts_st 'CA'
    ts_zip_code '94105'
    zip_code '94105'

    initialize_with { new(attributes) }
  end
end
