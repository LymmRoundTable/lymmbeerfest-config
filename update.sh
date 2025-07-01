#! /bin/bash

git pull
cd export-import
ruby convert_csv_to_json.rb | ruby update_config.rb > config_updated.json
mv config_updated.json ../config.json
git add config.json
git commit -am "Automatic update from CSV"
git push
