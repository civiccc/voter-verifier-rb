require 'service_utilities'

# Represents a voter address in the votizen_verifiers index, a subset of fields of the voters document
class VoterRecordAddress < ElasticSearchDocument
  include EnumConversion

  attributes %i[
    address
    address_apt_number
    address_street_name
    address_street_number
    address_unit_designator
    city
    st
    zip_code
    ts_address
    ts_address_apt_number
    ts_address_street_name
    ts_address_street_number
    ts_address_unit_designator
    ts_city
    ts_st
    ts_zip_code
  ]

  def initialize(document, score: nil)
    @document = document.deep_symbolize_keys!
    @score = score
  end

  def to_thrift
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

  private

  def ts_address_field(field_name)
    send(field_name) || send("ts_#{field_name}")
  end
end
