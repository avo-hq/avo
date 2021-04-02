#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

# Initial bump
gem bump --no-commit

# update the appraisal gemspecs
bundle exec appraisal install

# Get the version
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

git add ./gemfiles
git add ./version.rb
git add ./Gemfile.lock

# echo "Bump $NAME to v$VERSION"
git commit -m "Bump $NAME to v$VERSION"
git tag v$VERSION

# git push --follow-tags
