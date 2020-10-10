#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

bundle exec bump $BUMP --tag
VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

git push --follow-tags
