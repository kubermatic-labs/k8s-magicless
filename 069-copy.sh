#!/bin/bash

set -euxo pipefail

for node in controller-{0..2}; do
  gcloud compute scp 070-controlplane-master.sh ${node}:
done