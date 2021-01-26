## Istio Installer
This image is used by the rancher istio dev-chart to intall istio with various configurations 

Scripts include install, upgrade and uninstall. 

## Build
Image is built when a new tag is created and pushed to repository.

```
git tag <x.x.x>-rancher<x>
git push <istio_installer_remote_branch> <x.x.x>-rancher<x>
```

Tag version format: <x.x.x>-rancher<x>

<x.x.x> - istio version
rancher<x> - Build number. Starting at 1 and increases with each re-tag with the same istio version.

Example local build:
```sh
TAG=<x.x.x>-rancher<x> make
```