require 'base64'
require 'thrift'

module ThriftUtils
  module Thrift
    # ThriftSerializer enables serializing and deserializing of Thrift
    # objects, with the option of using strict base 64 encoding and decoding.
    # The reason we are opting to write our own Thrift serializer as opposed
    # to using Saltside Base64 module is because that library uses 'encode'
    # rather than 'strict_encode' logic, which will never output new lines
    # thus breaking our HTTP headers if we use that library on our Thrift
    # RequestHeaders.
    module Serializer
      PROTOCOL_FACTORY = ::Thrift::BinaryProtocolFactory
      DESERIALIZER = ::Thrift::Deserializer.new(PROTOCOL_FACTORY.new)
      SERIALIZER = ::Thrift::Serializer.new(PROTOCOL_FACTORY.new)

      class << self
        def serialize(thrift_object)
          SERIALIZER.serialize(thrift_object)
        end

        def deserialize(thrift_struct, serialized_thrift_object)
          DESERIALIZER.deserialize(thrift_struct, serialized_thrift_object)
        end

        def to_base64(thrift_object)
          Base64.strict_encode64(serialize(thrift_object))
        end

        def from_base64(thrift_struct, serialized_thrift_object)
          deserialize(thrift_struct, Base64.strict_decode64(serialized_thrift_object))
        end
      end
    end
  end
end
