#!/bin/bash
echo "setting up kubeconfig"
export KUBECONFIG=$HOME/sa.kubeconfig
./usr/local/app/scripts/init_kubeconfig.sh

if $RELEASE_MIRROR_ENABLED; then
    echo "generating ssl certs"
    openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=github.com" -addext "subjectAltName=DNS:github.com" -newkey rsa:2048 -keyout /etc/ssl/private/github.com.key -out /etc/ssl/certs/github.com.crt   
    cp /etc/ssl/certs/github.com.crt /usr/local/share/ca-certificates/fake-github.com.crt
    update-ca-certificates
    echo "running nginx"
    nginx -c /etc/nginx/nginx.conf
fi
echo "starting istioctl commands"
./usr/local/app/scripts/create_istio_system.sh
