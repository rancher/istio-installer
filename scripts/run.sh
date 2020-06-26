#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh
echo "starting istioctl commands"
./usr/local/app/scripts/create_istio_system.sh