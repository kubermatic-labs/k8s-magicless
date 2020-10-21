#!/bin/bash

set -euxo pipefail

for node in controller-{0..2}; do
  gcloud compute scp 065-etcd-master.sh ${node}:
done