#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

# Initial bump
gem bump --no-commit
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

# update the appraisal gemspecs
bundle exec appraisal install

# Get the version again
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

gem bump -v $VERSION

# git push --follow-tags
