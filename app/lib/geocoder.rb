# Use a CSV file as a data source to build an in-memory map of zip codes -> lat/lng
class InMemoryGeocoder
  # @param csv_src [String] File-path of the CSV source data
  # @param zip_code_col [Integer] Index of the column containing the zip_code
  # @param lat_col [Integer] Index of the column containing the latitude
  # @param lng_col [Integer] Index of the column containing the longitude
  def initialize(csv_src, zip_code_col:, lat_col:, lng_col:)
    @zip_to_lat_lng_map = generate_lat_lng_map(csv_src, zip_code_col, lat_col, lng_col)
  end

  # Look up the given zip_code and return the corresponding lat/lng, if found
  # @param zip_code (String) zip_code to look up
  # @return [Hash] Hash with the corresponing lat/lng of the form {lat: [String], lng: [String]}
  def geocode(zip_code)
    @zip_to_lat_lng_map[zip_code]
  end

  private

  def generate_lat_lng_map(src, zip_code_col, lat_col, lng_col)
    CSV.foreach(src, headers: :first_row).each_with_object({}) do |row, hash|
      hash[row[zip_code_col]] = { lat: row[lat_col], lng: row[lng_col] }
    end.freeze
  end
end
