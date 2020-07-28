#!/bin/bash
istioctl version
old_versions=$(kubectl get --ignore-not-found=true deploy istio-pilot -n istio-system -o=jsonpath='{$.spec.template.spec.containers[*].image}')
# check if older version of istio is still installed in istio-system namespace
if [[ $old_versions == *"1.3"* || $old_versions == *"1.4"* || $old_versions == *"1.5"* ]]; then
    echo "Please uninstall current istio version before attempting to install $ISTIO_VERSION"
fi

versions=$(kubectl get --ignore-not-found=true deploy istiod -n istio-system -o=jsonpath='{$.spec.template.spec.containers[*].image}')
if [[ $CANARY_REVISION ]] || [[ $versions == "" ]]
then
    if test -f "/app/overlay-config.yaml"
    then
        echo "Running istioctl install with overlay"
        istioctl install -y  -f /app/istio-base.yaml -f /app/overlay-config.yaml
        istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml > /app/generated-manifest.yaml
        istioctl verify-install -f /app/generated-manifest.yaml
    else
        echo "Running istioctl install"
        istioctl install -y -f /app/istio-base.yaml
        istioctl manifest generate -f /app/istio-base.yaml > /app/generated-manifest.yaml
        istioctl verify-install -f /app/generated-manifest.yaml
    fi
else
    if test -f "/app/overlay-config.yaml"
    then
        echo "Running istioctl upgrade with overlay"
        istioctl upgrade -y  -f /app/istio-base.yaml -f /app/overlay-config.yaml
        istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml > /app/generated-manifest.yaml
        istioctl verify-install -f /app/generated-manifest.yaml
    else
        echo "Running istioctl upgrade"
        istioctl upgrade -y -f /app/istio-base.yaml
        istioctl manifest generate -f /app/istio-base.yaml > /app/generated-manifest.yaml
        istioctl verify-install -f /app/generated-manifest.yaml
    fi
fi
