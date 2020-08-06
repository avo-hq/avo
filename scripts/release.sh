#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

gem bump $BUMP --no-commit
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')
bundle install --quiet
git add .
git commit -m "Bump $NAME to $VERSION"
gem tag
git push --tags
