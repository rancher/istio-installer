#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh
if test -f "/app/overlay-config.yaml"
then
    echo "Uninstalling istio and overlay file"
    istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml | kubectl delete -f -
else
    echo "Uninstalling istio"
    istioctl manifest generate -f /app/istio-base.yaml | kubectl delete -f -
fi
kubectl delete namespace istio-system
