#!/bin/bash

echo "generating ssl certs"
./usr/local/app/scripts/generate_ssl.sh
echo "custom /etc/hosts"
echo '127.0.0.1 github.com' >> /etc/hosts
echo "running nginx"
nginx
