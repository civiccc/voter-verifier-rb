FactoryBot.define do
  factory :search_query_args, class: Hash do
    first_name 'Testy'
    middle_name 'Quincy'
    last_name 'McTesterson'
    dob Date.new(2014, 8, 1)
    email 'testy.mctesterson@gmail.com'
    phone '123-456-7890'
    street_address '***REMOVED***'
    city 'San Francisco'
    state 'CA'
    zip_code '94118'
    max_results 3

    initialize_with { attributes }
  end
end
