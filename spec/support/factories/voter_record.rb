FactoryBot.define do
  factory :voter_record, class: VoterRecord do
    doc Hash.new foo: 'bar'

    initialize_with { new(attributes) }
  end
end
