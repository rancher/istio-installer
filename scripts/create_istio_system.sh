#!/bin/bash
istioctl version
istioctl install --set revision=${RELEASE_NAME} -f /app/config.yaml
istioctl verify-install --revision ${RELEASE_NAME}