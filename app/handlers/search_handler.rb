# RPC handlers for searching voting vecords
class SearchHandler < ThriftServer::ThriftHandler
  include ThriftServer::Middleware::SkylightInstrumentation::Mixin

  process ThriftShop::Verification::VerificationService, only: %i[]
end
