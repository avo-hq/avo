#!/bin/bash

set -e

BUMP=$1

gem bump $BUMP
VERSION=$(bundle exec rails runner 'puts Avocado::VERSION')
git tag v$VERSION
git push --tags
