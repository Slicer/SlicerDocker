#!/usr/bin/env bash

# This script downloads and extracts Slicer and selected extensions to a target
# directory. It depends on rsync, curl, and jq.
#
# args: [-v release_id] [-e extension] [-d dest] [-s]
# Installs extensions into slicer at dest. multiple -e arguments are accepted; each
#   extension will be installed.
# If -s is present, slicer itself is installed at dest.
# If -v is not present, assume 4.11.20210226 (current slicer stable)

# Usage:
# Install slicer to ./stable
#   slicer-download.sh -v 4.11.20210226 -d stable -s

# Add BoneTextureExtension to that installation
#   slicer-download.sh -v 4.11.20210226 -d stable -e BoneTextureExtension

# Do both steps at once
#   slicer-download.sh -v 4.11.20210226 -d stable -s -e BoneTextureExtension

set -e
set -o pipefail

if [[ ! $OSTYPE =~ ^linux ]]; then
    echo 'slicer-download.sh currently only supports linux installations.'
    exit
fi

declare -a EXTENSIONS

while getopts ":v:e:d:s" opt; do
  case "$opt" in
    v)
      REVISION="${OPTARG}"
      ;;
    e)
      EXTENSIONS+=("${OPTARG}")
      ;;
    d)
      TARGET="${OPTARG}"
      ;;
    s)
      INSTALL_SLICER='yes'
      ;;
    *)
      >&2 echo "Unrecognized argument ${OPTARG}"
      ;;
  esac
done

BASE_URL="https://slicer-packages.kitware.com/api/v1"
APP_ID=$(curl -s "$BASE_URL/app?name=Slicer&limit=1" | jq -r '.[0]._id')

# this would only work on linux since package must be .tar.gz
PACK_OS="linux"
PACK_ARCH="amd64"

function release() {
  # fetch the lowerName of the most-recent release
  curl -s "$BASE_URL/app/$APP_ID/release?sort=meta.revision&sortdir=-1" | jq -r '.[0].lowerName'
}

function package() {
  # args: release_id
  curl -s "$BASE_URL/app/$APP_ID/package?release_id_or_name=$1&os=$PACK_OS&arch=$PACK_ARCH&limit=1" | jq '.[0]'
}

function extension() {
  # args: baseName app_revision
  curl -s "$BASE_URL/app/$APP_ID/extension?baseName=$1&app_revision=$2&os=$PACK_OS&arch=$PACK_ARCH&limit=1" | jq '.[0]'
}

function download() {
  # args: id
  curl -# "$BASE_URL/item/$1/download"
}

function flatten() {
  # args: src dest
  # joins all directories in src into one directory called dest.

  rsync -a "$1"/*/* "$2"
}

REVISION="${REVISION:-"$(release)"}"
TARGET="${TARGET:-"Slicer-$REVISION"}"

>&2 echo "Installing to $TARGET (version $REVISION): ${INSTALL_SLICER:+"Slicer "}${EXTENSIONS[*]}"

PACK=$(package "$REVISION")

PACK_ID=$(jq -r '._id' <<< "$PACK")
PACK_REV=$(jq -r '.meta.revision' <<< "$PACK")
PACK_NAME=$(jq -r '.name' <<< "$PACK")

TEMP=$(mktemp -d)

if [[ -n $INSTALL_SLICER ]]; then
  >&2 echo "Downloading Slicer: $PACK_NAME"
  download "$PACK_ID" | tar xz -C "$TEMP"
fi

for EXTENSION in "${EXTENSIONS[@]}"; do
  EXT=$(extension "$EXTENSION" "$PACK_REV")

  EXT_NAME=$(jq -r '.name' <<< "$EXT")
  EXT_ID=$(jq -r '._id' <<< "$EXT")

  >&2 echo "Downloading $EXTENSION: $EXT_NAME"
  download "$EXT_ID" | tar xz -C "$TEMP"
done


>&2 echo "Installing to $TARGET"
flatten "$TEMP" "$TARGET"

echo "$TARGET"
