#!/bin/bash
istioctl version -i $ISTIO_NAMESPACE

ISTIO_FILES=("/app/istio-base.yaml")
if test -f "/app/overlay-config.yaml"; then
    echo "creating istio system using overlay"
    ISTIO_FILES+=("/app/overlay-config.yaml")
fi

if [[ $FORCE_INSTALL != true ]]; then
  old_versions=$(kubectl get --ignore-not-found=true deploy istio-pilot -n istio-system -o=jsonpath='{$.spec.template.spec.containers[*].image}')
  # check if older version of istio is still installed in istio-system namespace
  if [[ $old_versions == *"1.3"* || $old_versions == *"1.4"* || $old_versions == *"1.5"* ]]; then
      echo "please uninstall current istio version in istio-system namespace before attempting to install $ISTIO_VERSION"
      exit 1
  fi
  # force install will skip file checks. same analyze command is valid for install and upgrade
  istioctl analyze $ISTIO_FILES -i $ISTIO_NAMESPACE --failure-threshold Error
  if [[ $? -ne 0 ]]; then
    echo "error found during istioctl analyze"
    exit 1
  fi
fi

versions=$(kubectl get --ignore-not-found=true deploy istiod -n $ISTIO_NAMESPACE -o=jsonpath='{$.spec.template.spec.containers[*].image}')
if [[ $versions == "" ]]; then
  echo "running istioctl install"
  istioctl install -i $ISTIO_NAMESPACE -y ${ISTIO_FILES[@]/#/-f }

else
  echo "running istioctl upgrade"
  istioctl upgrade -i $ISTIO_NAMESPACE -y ${ISTIO_FILES[@]/#/-f }
fi
istioctl manifest generate -i $ISTIO_NAMESPACE ${ISTIO_FILES[@]/#/-f } > /app/generated-manifest.yaml
istioctl verify-install -i $ISTIO_NAMESPACE -f /app/generated-manifest.yaml
