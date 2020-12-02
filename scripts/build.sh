#!/bin/bash

set -e

VERSION=$(ruby -r './lib/avo/version.rb' -e 'puts Avo::VERSION')

docker build -t avo-build -f docker/Dockerfile .
IMAGE_ID=$(docker create avo-build)
rm ./pkg/latest-avo.gem 2> /dev/null
docker cp $IMAGE_ID:/avo/pkg/avo-$VERSION.gem ./pkg/latest-avo.gem
