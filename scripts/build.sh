#!/bin/bash

set -e

rm -rf public/avo-packs
bin/webpack
gem build avo --output pkg/avo.gem
