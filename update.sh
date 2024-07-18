#! /bin/bash

git pull
cd export-import
ruby export_from_sheets.rb | ruby update_config.rb > ../config.json
cd ..
git commit -am "Automatic update from Google sheet"
#git push
