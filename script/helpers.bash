# Helper script to be sourced by other scripts that run tests.
#
# This is intended to expose a basic set of helpers that we can use to DRY up
# tests scripts.

set -euo pipefail

source /***REMOVED***
source /***REMOVED***

wait-for-elasticsearch() {
  echo "Waiting for Elasticsearch..."
  dockerize -timeout 30s -wait http://${ELASTICSEARCH_HOST:-127.0.0.1}:${ELASTICSEARCH_PORT:-9200} \
    echo "Elasticsearch ready!" && return

  error "Could not connect to Elasticsearch!"
  docker-compose logs --tail=20 elasticsearch
  return 1
}

install-gems() {
  echo "Starting bundle install..."
  BUNDLE_IGNORE_CONFIG=1 bundle install --jobs=$(nproc) --retry=3 $@
}

install-deployment-gems() {
  install-gems --deployment
}
