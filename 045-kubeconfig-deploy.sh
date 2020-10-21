#!/bin/bash

set -euxo pipefail

for node in worker-{0..2}; do
  gcloud compute scp ${node}.kubeconfig kube-proxy.kubeconfig $node:
done

for node in controller-{0..2}; do
  gcloud compute scp \
    {admin,kube-controller-manager,kube-scheduler}.kubeconfig \
    ${node}:
done
