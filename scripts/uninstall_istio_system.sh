#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh
if test -f "/app/overlay-config.yaml"
then 
    echo "Unistalling istio and overlay file"    
    istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml | kubectl delete -f -
else 
    echo "Unistalling istio"
    istioctl manifest generate -f /app/istio-base.yaml | kubectl delete -f -
kubectl delete namespace istio-system
