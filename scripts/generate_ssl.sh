#!/bin/bash

openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=Company, Inc./CN=github.com" -addext "subjectAltName=DNS:github.com" -newkey rsa:2048 -keyout /etc/ssl/private/github.com.key -out /etc/ssl/certs/github.com.crt
cp /etc/ssl/certs/github.com.crt /usr/local/share/ca-certificates/fake-github.com.crt
update-ca-certificates