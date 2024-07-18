#! /usr/bin/ruby

require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

SPREADSHEET_ID = '14EW-aF_ohSUmvloe7S_AYdlopPvTaZ-3g89mSpeK9sY'
SHEET_NAME = 'Beer List'
RANGE = 'A1:P100'
TITLE_MAPPING = {
  '#' => 'number',
  'Brewery' => 'brewery',
  'Beer' => 'name',
  'Description' => 'description',
  'Type' => 'type',
  'Colour' => 'colour',
  'Gluten Free' => 'glutenFree',
  'Vegan' => 'veganFriendly',
  'ABV' => 'abv',
  'Sponsor' => 'sponsor',
  'SponsorUrl' => 'sponsorUrl',
  'SponsorImageUrl' => 'sponsorImageUrl'
}
TYPE_MAPPING = {
  'abv' => :double,
  'glutenFree' => :boolean,
  'veganFriendly' => :boolean
}

####
####
########## Shouldn't need to modify below here ##########
####
####

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Lymm Beerfest Config Exporter'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.pwd, '.credentials', 'sheets.lymmbeerfest.yaml')
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

def strip_string(value)
  value.nil? ? value : value.strip
end

# Define the type casting method
def cast_value(value, type)
  case type
  when :boolean
    %w[true 1].include?(value.to_s.downcase)
  when :integer
    value.to_i
  when :float, :double
    value.to_f
  else
    strip_string(value)
  end
end

# Initialize the API
service = Google::Apis::SheetsV4::SheetsService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Get the sheet values
sheet_range = "#{SHEET_NAME}!#{RANGE}"
values_response = service.get_spreadsheet_values(SPREADSHEET_ID, sheet_range)
values = values_response.values
original_titles = values.first   # Get the first row as titles
data = values[1..-1]   # Remaining rows as data
titles = original_titles.select { |title| TITLE_MAPPING.key?(title) }.map { |title| TITLE_MAPPING[title] }   # Convert sheet titles to JSON field names
indices_to_include = original_titles.each_index.select { |index| TITLE_MAPPING.key?(original_titles[index]) }   # Only grab fields that JSON needs

# Convert each row to a hash with titles as keys
rows_as_hashes = data.map do |row|
  row_filtered = indices_to_include.map { |index| row[index] }
  Hash[titles.zip(row_filtered)].transform_values.with_index { |value, idx| cast_value(value, TYPE_MAPPING[titles[idx]]) }
end

# Filter empty rows
rows_as_hashes = rows_as_hashes.reject { |row| row['number'].nil? || row['number'].empty? }

# Convert the array of hashes to JSON
puts JSON.pretty_generate(rows_as_hashes)