#!/bin/bash

set -e

NAME=Avocado
BUMP=${1:-'patch'}

gem bump $BUMP --no-commit
VERSION=$(bundle exec rails runner 'puts Avocado::VERSION')
bundle install --quiet
git add .
# git commit -m "Bump $NAME to $VERSION"
# gem tag
git tag -am "tag v$VERSION" v$VERSION
# git add Gemfile.lock
# git tag v$VERSION
git push --tags
