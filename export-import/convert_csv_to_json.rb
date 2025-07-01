#! /usr/bin/ruby

require 'csv'
require 'fileutils'
require 'json'

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
  'Sub Type' => 'subtype',
  'Sponsor' => 'sponsor',
  'SponsorUrl' => 'sponsorUrl',
  'SponsorImageUrl' => 'sponsorImageUrl'
}
TYPE_MAPPING = {
  'abv' => :double,
  'glutenFree' => :boolean,
  'veganFriendly' => :boolean
}

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

values = CSV.read('../beerlist.csv', headers: true)
original_titles = values.headers
data = values.map(&:fields)
titles = original_titles.select { |title| TITLE_MAPPING.key?(title) }.map { |title| TITLE_MAPPING[title] }
indices_to_include = original_titles.each_index.select { |index| TITLE_MAPPING.key?(original_titles[index]) }

rows_as_hashes = data.map do |row|
  row_filtered = indices_to_include.map { |index| row[index] }
  Hash[titles.zip(row_filtered)].transform_values.with_index { |value, idx| cast_value(value, TYPE_MAPPING[titles[idx]]) }
end

rows_as_hashes = rows_as_hashes.reject { |row| row['number'].nil? || row['number'].empty? }

puts JSON.pretty_generate(rows_as_hashes)