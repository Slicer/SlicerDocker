#!/usr/bin/env bash

set -e
set -o pipefail

images=( $(docker images --filter dangling=true -q 2>/dev/null) )
if [ ${#images[@]} -gt 1 ]; then
  echo "Removing ${#images[@]} dangling images"
  docker rmi "${images[@]}" 2>/dev/null
fi
