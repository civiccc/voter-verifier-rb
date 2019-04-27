require 'thrift_shop'

FactoryBot.define do
  factory :entity, class: ThriftShop::Shared::Entity do
    uuid { SecureRandom.uuid }
    role { ThriftShop::Shared::EntityRole::USER }

    trait(:user) { role { ThriftShop::Shared::EntityRole::USER } }
    trait(:guest) { role { ThriftShop::Shared::EntityRole::GUEST } }
  end
end
