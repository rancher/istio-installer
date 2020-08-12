#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh

ISTIO_FILES=("/app/istio-base.yaml")
if test -f "/app/overlay-config.yaml"; then
    echo "uninstalling istio system using overlay"
    ISTIO_FILES+=("/app/overlay-config.yaml")
fi

echo "uninstalling istio"
istioctl manifest generate -i $ISTIO_NAMESPACE ${ISTIO_FILES[@]/#/-f } | kubectl delete --ignore-not-found=true -f -
