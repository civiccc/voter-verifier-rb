require 'thrift_defs'

FactoryBot.define do
  factory :request_headers, class: ThriftDefs::RequestTypes::Headers do
    request_id { SecureRandom.uuid }
    context { FactoryBot.build(:request_context) }

    trait(:user) { entity { FactoryBot.build(:entity, :user) } }
    trait(:guest) { entity { FactoryBot.build(:entity, :guest) } }
  end
end
