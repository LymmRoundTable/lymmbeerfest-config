#! /usr/bin/ruby

require 'open-uri'
require 'json'

beers = JSON.parse(STDIN.read)

# Modify the existing config
original_json = JSON.parse(File.read('../config.json'))
original_json[:brews] = beers
updated_json = JSON.pretty_generate(original_json)

puts update_json
