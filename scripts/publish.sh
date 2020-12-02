#!/bin/bash

set -e

VERSION=$(ruby -r './lib/avo/version.rb' -e 'puts Avo::VERSION')

gem build avo.gemspec
gem push --key github --host https://rubygems.pkg.github.com/avo-hq ./pkg/avo-$VERSION.gem
