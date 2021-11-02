#!/bin/bash
ca=$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt | base64 -w 0)
token=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
server=https://${KUBERNETES_SERVICE_HOST}
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
    namespace: ${ISTIO_NAMESPACE}
    user: ${RELEASE_NAME}-user
current-context: default-context
users:
- name: ${RELEASE_NAME}-user
  user:
    token: ${token}
" > $KUBECONFIG
kubectl config --kubeconfig=$HOME/sa.kubeconfig use-context ${RELEASE_NAME}-context
