#! /bin/bash

cd export-import
ruby export-import/export_from_sheets.rb | ruby export-import/update_config.rb > ../config.json
cd ..
git commit -am "Automatic update from Google sheet"
#git push
