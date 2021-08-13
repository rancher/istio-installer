#!/bin/bash
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh

if NGINX_ENABLED; then
    echo "setting up release mirror"
    ./usr/local/app/scripts/setup_release_mirror.sh
fi
echo "starting istioctl commands"
./usr/local/app/scripts/create_istio_system.sh
