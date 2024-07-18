#! /usr/bin/ruby

require 'open-uri'
require 'json'

beers = JSON.parse(STDIN.read)

# Modify the existing config
file_contents = File.read('../config.json')

original_json = JSON.parse(file_contents)
original_json['brews'] = beers
original_json['version'] = original_json['version'].to_i + 1
updated_json = JSON.pretty_generate(original_json)

puts updated_json
