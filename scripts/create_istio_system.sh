#!/bin/bash
istioctl version -i $ISTIO_NAMESPACE
if [[ $FORCE_INSTALL == false ]]; then
  old_versions=$(kubectl get --ignore-not-found=true deploy istio-pilot -n istio-system -o=jsonpath='{$.spec.template.spec.containers[*].image}')
  # check if older version of istio is still installed in istio-system namespace
  if [[ $old_versions == *"1.3"* || $old_versions == *"1.4"* || $old_versions == *"1.5"* ]]; then
      echo "please uninstall current istio version before attempting to install $ISTIO_VERSION"
      exit 1
  fi
  # force install will skip file checks. same analyze command is valid for install and upgrade
  if test -f "/app/overlay-config.yaml"; then
    echo "running istioctl analyze with overlay"
    istioctl analyze /app/istio-base.yaml /app/overlay-config.yaml -i $ISTIO_NAMESPACE --failure-threshold Error
  else
    echo "running istioctl analyze"
    istioctl analyze /app/istio-base.yaml -i $ISTIO_NAMESPACE --failure-threshold Error
  fi
  if [[ $? -ne 0 ]]; then
    echo "error found during istioctl analyze"
    exit 1
  fi
fi

versions=$(kubectl get --ignore-not-found=true deploy istiod -n $ISTIO_NAMESPACE -o=jsonpath='{$.spec.template.spec.containers[*].image}')
if [[ $CANARY_REVISION ]] || [[ $versions == "" ]]; then
    if test -f "/app/overlay-config.yaml"; then
        echo "running istioctl install with overlay"
        istioctl install -y  -f /app/istio-base.yaml -f /app/overlay-config.yaml
        istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml > /app/generated-manifest.yaml
        istioctl verify-install -i $ISTIO_NAMESPACE -f /app/generated-manifest.yaml
    else
        echo "running istioctl install"
        istioctl install -y -f /app/istio-base.yaml
        istioctl manifest generate -f /app/istio-base.yaml > /app/generated-manifest.yaml
        istioctl verify-install -i $ISTIO_NAMESPACE -f /app/generated-manifest.yaml
    fi
else
    if test -f "/app/overlay-config.yaml"; then
        echo "running istioctl upgrade with overlay"
        istioctl upgrade -y  -f /app/istio-base.yaml -f /app/overlay-config.yaml
        istioctl manifest generate -f /app/istio-base.yaml -f /app/overlay-config.yaml > /app/generated-manifest.yaml
        istioctl verify-install -i $ISTIO_NAMESPACE -f /app/generated-manifest.yaml
    else
        echo "running istioctl upgrade"
        istioctl upgrade -y -f /app/istio-base.yaml
        istioctl manifest generate -f /app/istio-base.yaml > /app/generated-manifest.yaml
        istioctl verify-install -i $ISTIO_NAMESPACE -f /app/generated-manifest.yaml
    fi
fi
