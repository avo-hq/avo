#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

# Initial bump
gem bump --version $BUMP --no-commit

# update the appraisal gemspecs
bundle exec appraisal install

# Get the version
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')
MESSAGE="Bump $NAME to v$VERSION"
TAG="v$VERSION"

git add ./gemfiles
git add ./lib/avo/version.rb
git add ./Gemfile.lock

git commit -m "$MESSAGE"
git tag -a -m "$MESSAGE" $TAG

git push --follow-tags
