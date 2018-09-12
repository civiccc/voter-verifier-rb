# Helper script to be sourced by other scripts that run tests.
#
# This is intended to expose a basic set of helpers that we can use to DRY up
# tests scripts.

set -euo pipefail

source /***REMOVED***
source /***REMOVED***

wait-for-mysql() {
  echo "Waiting for MySQL..."
  dockerize -timeout 30s -wait tcp://${MYSQL_HOST:-127.0.0.1}:3306 \
    echo "MySQL ready!" && return

  error "Could not connect to MySQL!"
  docker-compose logs --tail=20 mysql
  return 1
}

ensure-schema-up-to-date() {
  bundle exec rake db:create 2>/dev/null || true
  bundle exec rake db:migrate
}

install-gems() {
  echo "Starting bundle install..."
  BUNDLE_IGNORE_CONFIG=1 bundle install --jobs=$(nproc) --retry=3 $@
}

install-deployment-gems() {
  install-gems --deployment
}
