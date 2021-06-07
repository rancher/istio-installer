#!/bin/bash

# https://istio.io/latest/docs/ops/integrations/grafana/#option-1-quick-start
for DASHBOARD in 7639 11829 7636 7630 7642 7645; do
  REVISION="$(curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions -s | jq ".items[] | select(.description | endswith(\"${ISTIO_VERSION}\")) | .revision")"
  curl -s https://grafana.com/api/dashboards/${DASHBOARD}/revisions/${REVISION}/download > /usr/local/app/dashboards/${DASHBOARD}.json
done
