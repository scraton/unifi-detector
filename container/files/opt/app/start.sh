#!/bin/bash
set -xe

is_defined() {
  if [ -z "${!1}" ]; then
    echo "ERROR: $1 not defined"
    exit 1
  fi
}

# Add a bunch of environment variable assertions here. Using this function,
# the start script will fail if the environment variables you expected are
# not defined. For example:
#
# is_defined my_setting

/usr/local/bin/confd -onetime -backend=env

exec /opt/app/unifi-detector "$@"
