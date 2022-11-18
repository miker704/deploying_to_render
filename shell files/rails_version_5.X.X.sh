#!/usr/bin/env bash

# exit on error
set -o errexit
# npm install
npm run build
bundle install
rails db:migrate
bundle exec rake assets:precompile
rails db:seed #if needed