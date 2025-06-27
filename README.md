# Updating the config
1. Modify the Beers spreadsheet, for 2025 this is https://drive.google.com/drive/u/0/folders/1YZUWo4p_xvN_pD-z9daoV0L5YB9zKfRo
2. `git checkout https://github.com/LymmRoundTable/lymmbeerfest-config`
3. `./update.sh`

You'll be prompted for Google OAuth. As this is a private solution you'll need to havee your Google Account added to the list of authorised OAuth.

This will only update the beers in the config.json. Anything else (gins, bands, times, prices, etc) needs to be done by hand and bump the version number before committing.
