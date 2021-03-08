#!/bin/bash

set -e

VERSION=$(bundle exec rails runner 'puts Avo::VERSION')

docker build -t avo-build -f docker/Dockerfile .
IMAGE_ID=$(docker create avo-build)
rm -f ./pkg/latest-avo.gem
docker cp $IMAGE_ID:/avo/pkg/avo-$VERSION.gem ./pkg/latest-avo.gem
