SEVERITIES = HIGH,CRITICAL

ifeq ($(TAG),)
TAG = dev
endif

.PHONY: all
all:
	docker build --build-arg TAG=$(TAG) -t brendarearden/istio-installer:$(TAG) .

.PHONY: image-push
image-push:
	docker push brendarearden/istio-installer:$(TAG) >> /dev/null

.PHONY: scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --skip-update --ignore-unfixed brendarearden/istio-installer:$(TAG)

.PHONY: image-manifest
image-manifest:
	docker image inspect brendarearden/istio-installer:$(TAG)
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create brendarearden/istio-installer:$(TAG) \
		$(shell docker image inspect brendarearden/istio-installer:$(TAG) | jq -r '.[] | .RepoDigests[0]')
