# TODO use a slimmer CSV file for tests, pull from filename from configatron
lat_lng_src = File.join('data', 'zip_to_lat_lng.csv')

geocoder = InMemoryGeocoder.new(lat_lng_src, zip_code_col: 0, lat_col: 5, lng_col: 6).freeze
Queries::VoterRecord::Preprocessors::Address.geocoder = geocoder
