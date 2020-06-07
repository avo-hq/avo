#!/bin/bash

set -e

BUMP=$1

gem bump $BUMP
VERSION=$(bundle exec rails runner 'puts Avocado::VERSION')
gem tag
# git add Gemfile.lock
# git tag v$VERSION
git push --tags
