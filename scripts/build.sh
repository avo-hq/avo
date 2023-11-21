#!/bin/bash

set -e

VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

# Create v1.0.0 versions of the Gemfile and version file for better caching on the docker layer
mkdir -p tmp
cp ./Gemfile.lock ./tmp/Gemfile_v1.lock
sed -i '' 's/avo \(.*\)/avo (1.0.0)/' ./tmp/Gemfile_v1.lock
cp ./lib/avo/version.rb ./tmp/version_v1.rb
sed -i '' 's/VERSION = ".*"/VERSION = "1.0.0"/' ./tmp/version_v1.rb

docker build -t avo-3-build -f docker/Dockerfile . --progress plain
IMAGE_ID=$(docker create avo-3-build)

rm -f ./pkg/latest-avo.gem
docker cp $IMAGE_ID:/avo/pkg/avo-$VERSION.gem ./pkg/latest-avo.gem
