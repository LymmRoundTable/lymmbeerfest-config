#! /usr/bin/ruby

require 'open-uri'
require 'json'

beers = JSON.parse(STDIN.read)

# Modify the existing config
open('../config.json') do |original_file|
  original_json = JSON.parse(original_file.read)
  original_json[:brews] = beers
  updated_json = JSON.pretty_generate(original_json)
end

update_json
