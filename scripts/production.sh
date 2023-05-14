#!/bin/bash
set -e

echo -e '\e[32mVerifying credentials...\e[0m'
if [ ! -f config/master.key ]; then
  echo -e '\e[32mGenerating credentials...\e[0m'
  bin/rails credentials:edit
fi

echo -e '\e[32mPrecompiling Assets...\e[0m'
if ! RAILS_ENV=production bundle exec rails assets:precompile; then
  echo -e '\e[31;1mFailed precompiling your assets! Check the error above.'
  exit 1
fi

echo -e '\e[32mLaunching Server...\e[0m'
RAILS_ENV=production bundle exec rails server
