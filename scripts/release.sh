#!/bin/bash

set -e

NAME=Avo
BUMP=${1:-'patch'}

bundle exec bump $BUMP --tag
VERSION=$(ruby -r './lib/avo/version.rb' -e 'puts Avo::VERSION')

git push --follow-tags
