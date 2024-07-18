#! /bin/bash

git pull
cd export-import
ruby export_from_sheets.rb | ruby update_config.rb > ../config_updated.json
cd ..
mv config_updated.json config.json
# git add config.json
# git commit -am "Automatic update from Google sheet"
# git push
