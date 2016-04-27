#!/bin/bash

die() {
  echo "$@" 1>&2
  exit 1;
}

# The docker inspect format
function ver { printf "%03d%03d%03d" $(echo "$1" | tr '.' ' '); }
if [ $(ver $(docker version --format='{{.Client.Version}}')) -lt $(ver 1.10.0) ]; then
  die "Docker should be version 1.10.0 or newer"
fi

os=$(uname)
if [ "${os}" != "Linux" ]; then
  die "This script can only be used on Linux"
fi

if [ $# -lt 1 ]; then
  die "Usage: start-on-host.sh <slicer/slicer-build container name>"
fi
container_name=$1
container_id=$(docker ps -a -q --filter "name=${container_name}")
if [ -z "$container_id" ]; then
  die "Container: ${container_name} not found"
fi

volumes=$(docker inspect --format='{{.Config.Volumes}}' $container_id)
install_volume=$(expr "$volumes" : '.*/usr/src/install-prefix:\([^ ]*\)')

# /var/lib/docker commonly the docker directory and it is commonly only
# readable by root by default
if [ -d /var/lib/docker -a ! -x /var/lib/docker ]; then
  die "We need to inspect /var/lib/docker: please run 'sudo chmod 755 /var/lib/docker'"
fi
