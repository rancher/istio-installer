#!/bin/bash
ca=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w 0)
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
server=https://10.43.0.1
echo "
apiVersion: v1
kind: Config
clusters:
- name: ${RELEASE_NAME}-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: ${RELEASE_NAME}-context
  context:
    cluster: ${RELEASE_NAME}-cluster
    namespace: istio-system
    user: ${RELEASE_NAME}-user
current-context: default-context
users:
- name: ${RELEASE_NAME}-user
  user:
    token: ${token}
" > sa.kubeconfig
kubectl config --kubeconfig=sa.kubeconfig use-context ${RELEASE_NAME}-context 