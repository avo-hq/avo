#!/bin/bash

set -e

VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

gem build avo.gemspec
gem push --key github --host https://rubygems.pkg.github.com/AvocadoHQ ./avo-$VERSION.gem
