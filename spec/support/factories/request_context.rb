FactoryBot.define do
  factory :request_context, class: ThriftShop::Shared::RequestContext do
    trait(:with_invitation_uid) { invitation_uid SecureRandom.uuid }
  end
end
