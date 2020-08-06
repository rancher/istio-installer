#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh
if test -f "/app/overlay-config.yaml"; then
    echo "uninstalling istio and overlay file"
    istioctl manifest generate -i $ISTIO_NAMESPACE -f /app/istio-base.yaml -f /app/overlay-config.yaml | kubectl delete --ignore-not-found=true -f -
else
    echo "uninstalling istio"
    istioctl manifest generate -i $ISTIO_NAMESPACE -f /app/istio-base.yaml | kubectl delete --ignore-not-found=true -f -
fi
