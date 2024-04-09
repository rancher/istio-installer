#!/usr/bin/env bash

set -e

RELEASE_DIR=${1}
echo ${RELEASE_DIR}

# Istio versions that need to be supported in the image for airgap installation.
istio_version_array=(1.7.1 1.7.3 1.8.3 1.8.5 1.8.6 1.9.3 1.9.5 1.9.6 1.9.8 1.10.4 1.11.4 1.11.7 1.12.6 1.13.3 1.14.1 1.14.3 1.15.3 1.16.3 1.17.2 1.18.2 1.19.0 1.19.5 1.19.6 1.20.3 1.21.1)

if [ -z "${RELEASE_DIR}" ]; then
  echo "No directory given"
  exit 1
fi

if [ -d "${RELEASE_DIR}" ] ; then
  cd ${RELEASE_DIR}

  for v in "${istio_version_array[@]}"; do
    curl -sOL https://github.com/istio/istio/releases/download/$v/istio-$v-linux-amd64.tar.gz
  done

  for f in *.tar.gz; do
    if [ -f "$f" ]; then
      version=$(echo $f | grep -Eo '[0-9\.]+' | head -1)
      mkdir $version
      mv $f $version
    fi
  done
fi
