require 'thrift_defs'

FactoryBot.define do
  factory :entity, class: ThriftDefs::AuthTypes::Entity do
    uuid { SecureRandom.uuid }
    role { ThriftDefs::AuthTypes::EntityRole::USER }

    trait(:user) { role { ThriftDefs::AuthTypes::EntityRole::USER } }
    trait(:guest) { role { ThriftDefs::AuthTypes::EntityRole::GUEST } }
  end
end
