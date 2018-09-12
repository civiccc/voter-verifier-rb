require 'thrift_shop'

FactoryBot.define do
  factory :request_headers, class: ThriftShop::Shared::RequestHeaders do
    request_id { SecureRandom.uuid }
    context { FactoryBot.build(:request_context) }

    trait(:admin) { entity { FactoryBot.build(:entity, :admin) } }
    trait(:user) { entity { FactoryBot.build(:entity, :user) } }
    trait(:guest) { entity { FactoryBot.build(:entity, :guest) } }

    trait(:with_invitation_uid) do
      context { FactoryBot.build(:request_context, :with_invitation_uid) }
    end
  end
end
