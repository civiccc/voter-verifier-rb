require 'thrift_shop'

FactoryBot.define do
  factory :request_headers, class: ThriftShop::Shared::RequestHeaders do
    request_id { SecureRandom.uuid }
    context { FactoryBot.build(:request_context) }

    trait(:user) { entity { FactoryBot.build(:entity, :user) } }
    trait(:guest) { entity { FactoryBot.build(:entity, :guest) } }
  end
end
