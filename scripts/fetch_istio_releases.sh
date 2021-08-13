#!/usr/bin/env bash

set -e

RELEASE_DIR=${1}

echo ${RELEASE_DIR}

if [ -z "${RELEASE_DIR}" ]; then
  echo "No directory given"
  exit 1
fi

if [ -d "${RELEASE_DIR}" ] ; then
  cd ${RELEASE_DIR}

  dir=$(pwd)

  curl https://api.github.com/repos/istio/istio/releases | jq -r '.[] | select(.tag_name | test("^[0-9.]+$")) | .assets[] | select(.name | test("linux")) | .browser_download_url' | grep -v "sha256" | grep -v "arm" | grep -v "istioctl" | xargs -n 1 wget

  for f in *.tar.gz; do
    if [ -f "$f" ]; then
      version=$(echo $f | grep -Eo '[0-9\.]+' | head -1)
      mkdir $version
      mv $f $version
    fi
  done
fi
