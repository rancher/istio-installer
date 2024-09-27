# Istio Installer
This image is used by the [rancher-istio chart](https://github.com/rancher/charts "rancher-istio chart") to intall istio with various configurations.

This installer uses shell scripts to run istioctl install, upgrade and uninstall commands. 
## Architecture
Uses `istioctl` and `nginx` to complete install, upgrade and delete comands for the Istio service mesh. 

#### Overview
This image uses a series of bash scripts to execute `istioctl` binary comands. The `istioctl` binary is an Istio configuration command line utility for managing your Istio service mesh.

The current implementation of the `istioctl upgrade` command makes a call to external github to download Istio manifests to complete the upgrade process. This will fail when running in an airgapped enviornment. To temporarily resolve the issue, this image also uses an nginx server to intercept that call and download the necessary manifest from the docker container. The image bundles the Istio manifests for the versions of Istio that are currently released in a [rancher-istio chart](https://github.com/rancher/charts "rancher-istio chart").

## Making Changes
#### How to upgrade the istio version

1. In the Dockerfile, change the environmnet variable `ENV ISTIO_VERSION` to the version of istio that you would like the installer to support.
2. Finally, you need to validate that the create_istio_system.sh and the uninstall_istio_system.sh script commands are still valid. This can be done by checking that the [istioctl commands](https://istio.io/latest/docs/reference/commands/istioctl/ "istioctl commands") have not changed. You should also check the [release notes](https://istio.io/latest/news/ "release notes") for any significant changes to how istioctl is used. If there were changes to the commands, update the create_istio_system.sh  and the uninstall_istio_system.sh scripts accordingly.

## Build
The istio-installer image is built using drone when a new tag is created and pushed to repository. See drone.yaml for drone configurations.

When building and tagging the image locally, run `docker build -t <your_docker_hub_repo>/istio-installer:<tag> .`

####  How to tag
The istio installer uses the following version format for tags: `<x.x.x>-rancher<x>`

The `<x.x.x>` should be set to the version of istio the installer is going to be used for. This can be found in the Dockerfile as the value for the `ENV ISTIO_VERSION`

The `rancher<x>` is the build number. This number starts at 1 and increases with each re-tag with the same istio version.`

After all of the changes have been merged into the master branch, fetch a fresh copy of the master branch to your local machine. From there, you can run the following commands to tag and push the tag to the repo
```
git tag <x.x.x>-rancher<x>
git push <istio_installer_remote_branch> <x.x.x>-rancher<x>
```
Once the tag is pushed to github, drone will build the docker image and push it to the [rancher/istio-installer](https://hub.docker.com/r/rancher/istio-installer "rancher/istio-installer") docker hub repository.

**An example tag for a new istio version and push may look like this:**
```
git tag 1.9.6-rancher1
git push upstream 1.9.6-rancher1
```
If you need to re-tag the same version, that may look like this:
```
git tag 1.9.6-rancher2
git push upstream 1.9.6-rancher2
```

## Manual Tests

### Test the Standlone Docker Image
The first test is to run the docker image on its own (i.e not using the rancher-istio chart to run the image). This will allow you to more quickly find issues relating to the docker image configuration.

1. Build the docker image by running `docker build -t <your_docker_hub_repo>/istio-installer:<tag> .`

2. Run docker image by running `docker run <your_docker_hub_repo>/istio-installer:<tag>`.

Check the output for errors and fix them as found.

### Test Docker Image Works in Rancher-Istio chart
The second test is to check the docker image in the [rancher-istio chart](https://github.com/rancher/charts "rancher-istio chart"). This will help you identify any permission issues or additional configuration problems that were not identified in the standalone docker image test.

1. Build the docker image by running `docker build -t <your_docker_hub_repo>/istio-installer:<tag> .` Note: if you already built the image in the previous test, you do not need to build it again.
2. Push your image to docker hub by running `docker push <your_docker_hub_repo>/istio-installer:<tag>`.
3. Setup a rancher instance (can be single node or HA).
4. Create a large downstream cluster with default settings
5. In your downstream cluster, navigate to Apps & Market >> Charts.
6. Select rancher-istio, and install the latest version of istio (or version of istio that you are creating a bug fix for).
7. Select `system` project, edit options by disabling kiali (Note: only do this if you have not installed rancher-monitoring), then select eidt yaml and make the following updates to the yaml:

* update the `installer.repository`: to `repository: <your_docker_hub_repo>/istio-installer`,
* update the `installer.tag`: to tag: `<tag>`
* update the `installer.debug.secondsSleep`: to `secondsSleep: 30`
> Here is an example of those changes. This is not the entire values.yaml, it is just a small portion of it:
```
...
installer:
  debug:
    secondsSleep: 30
  releaseMirror:
    enabled: false
  repository: testuser/istio-installer
  tag: v1.0.0
...
```
8. Click install
9. Navigate to Workload >> Pods >> find the istio-installer pod and view logs to find an issues.
10. If no issues are found while checking the logs, see that the helm-operation results in a succesfull install and continue
11. Navigate to Apps & Marketplace >> Charts, select rancher-istio, click Update, leave default options, click Next, click Update
13. Navigate to Workload >> Pods >> find the istio-installer pod and view logs to see if there are any issues.
14. If there are issues, then Update usually fails.


### Test Image Mirror works in Rancher-Istio chart
The second test is to check the docker image in the [rancher-istio chart](https://github.com/rancher/charts "rancher-istio chart"). This will help you identify any permission issues or additional configuration problems that were not identified in the standalone docker image test.

1. Build the docker image by running `docker build -t <your_docker_hub_repo>/istio-installer:<tag> .` Note: if you already built the image in the previous test, you do not need to build it again.
2. Push your image to docker hub by running `docker push <your_docker_hub_repo>/istio-installer:<tag>`.
3. Setup a rancher instance (can be single node or HA).
4. Create a large downstream cluster with default settings
5. In your downstream cluster, navigate to Apps & Market >> Charts.
6. Select rancher-istio, and install the latest version of istio (or version of istio that you are creating a bug fix for).
7. Select `system` project, edit options by disabling kiali (Note: only do this if you have not installed rancher-monitoring), then select eidt yaml and make the following updates to the yaml:

* update the `installer.repository`: to `repository: <your_docker_hub_repo>/istio-installer`,
* update the `installer.tag`: to tag: `<tag>`
* update the `installer.debug.secondsSleep`: to `secondsSleep: 30`
> Here is an example of those changes. This is not the entire values.yaml, it is just a small portion of it:
```
...
installer:
  debug:
    secondsSleep: 30
  releaseMirror:
    enabled: false
  repository: testuser/istio-installer
  tag: v1.0.0
...
```
8. Click install
9. Navigate to Workload >> Pods >> find the istio-installer pod and view logs to find an issues.
10. If no issues are found while checking the logs, see that the helm-operation results in a succesfull install and continue
11. Navigate to Apps & Marketplace >> Charts, select rancher-istio, click Update, ensure the version in the dropdown is that same as selected on install, click next, and edit yaml to make the following updates:
* update the `installer.releaseMirror.enabled` to `enabled: true`.
> Here is an example of those changes. This is not the entire values.yaml, it is just a small portion of it:
```
...
installer:
  debug:
    secondsSleep: 30
  releaseMirror:
    enabled: true
  repository: testuser/istio-installer
  tag: v1.0.0
...
```
12. Click Update
13. Navigate to Workload >> Pods >> find the istio-installer pod and view logs to see if there are any issues.
14. If there are issues, then Update usually fails.
