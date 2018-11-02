namespace :search do
  desc 'Run everything but the thrift for a voter record search. Accepted env args:
    last_name
    first_name
    middle_name
    email
    dob
    zip_code
    city
    state
    street
    max_results (default: 3)
  '
  task test: :environment do
    begin
      dob = Date.parse(ENV['dob'])
    rescue TypeError, ArgumentError
      dob = nil
    end

    search_args = {
      max_results: ENV['max_results'].to_i || 3,
      last_name: ENV['last_name'],
      middle_name: ENV['middle_name'],
      first_name: ENV['first_name'],
      dob: dob,
      zip_code: ENV['zip_code'],
      city: ENV['city'],
      state: ENV['state'],
      street_address: ENV['street'],
      email: ENV['email'],
    }

    VoterVerification::SearchPrinter.new(search_args: search_args).run
  end

  desc 'Run everything but the thrift for a voter record search, verbosely. Accepted env args:
    last_name
    first_name
    middle_name
    email
    dob
    zip_code
    city
    state
    street
    max_results (default: 3)
  '
  task explain: :environment do
    begin
      dob = Date.parse(ENV['dob'])
    rescue TypeError, ArgumentError
      dob = nil
    end

    search_args = {
      max_results: ENV['max_results'].to_i || 3,
      last_name: ENV['last_name'],
      middle_name: ENV['middle_name'],
      first_name: ENV['first_name'],
      dob: dob,
      zip_code: ENV['zip_code'],
      city: ENV['city'],
      state: ENV['state'],
      street_address: ENV['street'],
      email: ENV['email'],
    }
    VoterVerification::SearchPrinter.new(search_args: search_args, verbose: true).run
  end
end
