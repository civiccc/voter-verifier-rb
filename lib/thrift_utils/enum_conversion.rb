require 'thrift_defs'

module ThriftUtils
  # TODO this can be generalized for any enum
  # Utilities module for enum conversions that happen in
  module EnumConversion
    THRIFT_TO_STATE_CODE = ThriftDefs::GeoTypes::StateCode::VALUE_MAP.freeze

    STATE_CODE_TO_THRIFT = THRIFT_TO_STATE_CODE.invert
    # Convert a state code string to its Thrift Enum
    def state_code_to_thrift(state_code:)
      STATE_CODE_TO_THRIFT.with_indifferent_access[state_code.upcase]
    end

    def thrift_to_state_code(enum:)
      THRIFT_TO_STATE_CODE[enum]
    end
  end
end
