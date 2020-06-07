#!/bin/bash

set -e

NAME=Avocado
BUMP=$1

gem bump $BUMP
gem bump --no-commit
VERSION=$(bundle exec rails runner 'puts Avocado::VERSION')
bundle
git commit -m "Bump $NAME to $VERSION"
gem tag
# git add Gemfile.lock
# git tag v$VERSION
git push --tags
