namespace :search do
  desc 'Run everything but the thrift for a voter record search. Accepted env args:
    last_name
    first_name
    middle_name
    dob
    zip_code
    city
    state
    street
    max_results (default: 3)
  '
  task test: :environment do
    query_args = {
      max_results: ENV['max_results'] || 3,
      last_name: ENV['last_name'],
      middle_name: ENV['middle_name'],
      first_name: ENV['first_name'],
      dob: ENV['dob'],
      zip_code: ENV['zip_code'],
      city: ENV['city'],
      state: ENV['state'],
      street_address: ENV['street'],
    }

    VoterVerification::SearchPrinter.new(query_args: query_args).run
  end

  desc 'Run everything but the thrift for a voter record search, verbosely. Accepted env args:
    last_name
    first_name
    middle_name
    dob
    zip_code
    city
    state
    street
    max_results (default: 3)
  '
  task explain: :environment do
    query_args = {
      max_results: ENV['max_results'] || 3,
      last_name: ENV['last_name'],
      middle_name: ENV['middle_name'],
      first_name: ENV['first_name'],
      dob: ENV['dob'],
      zip_code: ENV['zip_code'],
      city: ENV['city'],
      state: ENV['state'],
      street_address: ENV['street'],
    }
    VoterVerification::SearchPrinter.new(query_args: query_args, verbose: true).run
  end
end
