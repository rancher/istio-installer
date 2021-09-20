#!/bin/bash
echo "setting up kubeconfig"
export KUBECONFIG=$HOME/sa.kubeconfig
./usr/local/app/scripts/init_kubeconfig.sh

ISTIO_FILES=("/app/istio-base.yaml")
if test -f "/app/overlay-config.yaml"; then
    echo "uninstalling istio system using overlay"
    ISTIO_FILES+=("/app/overlay-config.yaml")
fi

echo "uninstalling istio"
istioctl manifest generate -i $ISTIO_NAMESPACE ${ISTIO_FILES[@]/#/-f } | kubectl delete --ignore-not-found=true -f -

if kubectl get namespace cattle-dashboards; then
  kubectl delete configmap -n cattle-dashboards -l istio_dashboard=1
fi
