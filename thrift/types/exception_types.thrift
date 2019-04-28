namespace rb ThriftDefs.ExceptionTypes

enum ExceptionClass {
  CLIENT = 0 ( description = "The request contains bad syntax or cannot be fulfilled" )
  SERVER = 1 ( description = "The server failed to fulfill an apparently valid request" )
  UPSTREAM = 2 ( description = "The server failed to fulfill an apparently valid request due to a condition outside its control" )
}

enum ArgumentExceptionCode {
  PRESENCE = 0 ( description = "The field was absent when it should have been present, or vice versa" ),
  INVALID = 1 ( description = "The field is invalid for some unspecified/generic reason" ),
  INVALID_LENGTH = 2 ( description = "The field has an invalid length" ),
  NOT_IN_SET = 3 ( description = "The field's value was not in the set of acceptable values" ),
}

enum StateExceptionCode {
  ALREADY_EXISTS = 0 ( description = "The state being created is already in place" ),
  LIMIT_REACHED = 1 ( description = "A limit in the state of resources has been hit (e.g. a maximum number allowed)" ),
  RESOURCE_NOT_FOUND = 2 ( description = "The resource being requested does not exist" ),
}

exception ArgumentException {
  1: string message,
  2: string path ( description = "The path to the problematic argument (represented as a series of dot-delimited field names)" ),
  3: ArgumentExceptionCode code,
  4: ExceptionClass exception_class = ExceptionClass.CLIENT,
} (
  description = "An exception that indicates a stateless validation issue with a provided argument. Retrying again with the same arguments will result in the same error.",
)

exception UnauthorizedException {
  1: string message,
  2: ExceptionClass exception_class = ExceptionClass.CLIENT,
}

exception StateException {
  1: string message,
  2: StateExceptionCode code,
  3: ExceptionClass exception_class = ExceptionClass.CLIENT,
} (
  description = "An exception that indicates the state of data in the service is different than what the client appeared to expect. Retrying again may or may not yield a different result, depending on the new state of the service.",
)
