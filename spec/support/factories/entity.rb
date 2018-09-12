require 'thrift_shop'

FactoryBot.define do
  factory :entity, class: ThriftShop::Shared::Entity do
    uuid { SecureRandom.uuid }
    role { ThriftShop::Shared::EntityRole::USER }

    trait(:admin) { role { ThriftShop::Shared::EntityRole::ADMIN } }
    trait(:user) { role { ThriftShop::Shared::EntityRole::USER } }
    trait(:guest) { role { ThriftShop::Shared::EntityRole::GUEST } }
  end
end
