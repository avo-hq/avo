#!/bin/bash

set -e

IMAGE_NAME=avo-dev
WORKSPACE_DIR=$1	BUMP=${1:-'patch'}
TAG=$2
OS=$(node -r os -e 'console.log(os.platform())')

cd $WORKSPACE_DIR

docker build -t $IMAGE_NAME -f docker/Dockerfile .

CID=$(docker create $IMAGE_NAME)

docker cp ${CID}:/avo/pkg/. $WORKSPACE_DIR/pkg
docker rm ${CID}
