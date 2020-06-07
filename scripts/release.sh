#!/bin/bash

set -e

NAME=Avocado
BUMP=${1:-'patch'}

gem bump $BUMP --no-commit
VERSION=$(bundle exec rails runner 'puts Avocado::VERSION')
bundle install --quiet
git add .
git commit -m "Bump $NAME to $VERSION"
gem tag
git push --tags
