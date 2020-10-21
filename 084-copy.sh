#!/bin/bash

set -euxo pipefail

for node in worker-{0..2}; do
  gcloud compute scp 085-worker.sh ${node}:
done