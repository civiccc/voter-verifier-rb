# These are a validators that can be used in RPC handlers to make assertions (beyond data type)
# about the values of particular fields.
module ThriftUtils
  module Validation
    # Checks if the given field of the request is not nil and throws a Thrift exception if it is.
    #
    # @param field [String] the name of the field to validate
    # @return [void]
    def verify_field_presence(field:, thrift_object: request, path_prefix: 'request')
      field_value = thrift_object.public_send(field)
      return unless field_value.nil? || field_value == ''
      raise ThriftDefs::ExceptionTypes::ArgumentException,
            message: 'Missing field',
            path: "#{path_prefix}.#{field}",
            code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::PRESENCE
    end

    # TODO anything that uses this should just be a union type
    # Similar to verify_field_presence, but takes an array of fields and checks that at least one
    # of them is not nil. Raises a Thrift exception if none are not nil.
    #
    # @param fields [Array<String>] the name of the field to validate
    # @return [void]
    def verify_at_least_one_field_present(fields, request)
      return unless fields.none? { |field| request.public_send(field) }

      raise ThriftDefs::ExceptionTypes::ArgumentException,
            message: "Missing field: at least one of #{fields} must be present",
            code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::PRESENCE
    end

    # Checks that a field that's expected to be a thrift `Date` or `DateTime` is a valid date/time.
    # Our prefered format of these is iso8601, but Thrift doesn't enforce this. They're just
    # strings. This method is for verifying that format and raising the right Thrift
    # Exception if it fails to parse.
    #
    # @param field [Symbol] the name of the field to validate
    # @param thrift_object [Object] Defaults to be the request, but can really be any object
    #   that responds to the field we're checking
    # @param path_prefix [String] defaults to 'request'. This is used to communicate about
    #   how to find the field that's bad. It should be set explicitly if thrift_object
    #   is anything other than the request. For example, if the thrift_object is the
    #   filter_params field of a request, this would be 'request.filter_params'
    # @return [void]
    def verify_date_time_field_format(field:, thrift_object: request, path_prefix: 'request')
      Time.parse(thrift_object.public_send(field))
    rescue ArgumentError
      raise ThriftDefs::ExceptionTypes::ArgumentException,
            message: "#{field} was not a valid Date or DateTime",
            path: "#{path_prefix}.#{field}",
            code: ThriftDefs::ExceptionTypes::ArgumentExceptionCode::INVALID
    end
  end
end
