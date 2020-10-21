#!/bin/bash
# some snippets you might not even need. (depends on your CNI choice)

set -euxo pipefail

# just list instance addresses
for node in worker-{0..2}; do
  gcloud compute instances describe ${node} \
    --format 'value[separator=" "](metadata.items[0].value,networkInterfaces[0].networkIP)'
done

exit 0


for x in {0..2}; do
  gcloud compute routes create k8s-pod-route-192-168-1${x}-0-24 \
    --network magicless-vpc \
    --next-hop-address 10.254.254.20${x} \
    --destination-range 192.168.1${x}.0/24
done


gcloud compute routes list --filter "network: magicless-vpc"

