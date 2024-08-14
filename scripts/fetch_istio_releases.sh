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


  curl -sOL https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istio-$ISTIO_VERSION-linux-amd64.tar.gz

  for f in *.tar.gz; do
    if [ -f "$f" ]; then
      version=$(echo $f | grep -Eo '[0-9\.]+' | head -1)
      mkdir $version
      mv $f $version
    fi
  done
fi
