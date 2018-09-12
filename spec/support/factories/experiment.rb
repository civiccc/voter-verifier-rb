FactoryBot.define do
  factory :experiment do
    sequence(:name) { |n| "Experiment-#{n}" }
  end
end
