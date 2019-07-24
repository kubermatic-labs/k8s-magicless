#!/bin/bash

# fortunately gcloud util can help with deploying to the nodes:
for node in worker-{0..2}; do
	gcloud compute scp ca.pem ${node}{,-key}.pem $node:
done

for node in controller-{0..2}; do
  gcloud compute scp ca{,-key}.pem kubernetes{,-key}.pem \
    service-account{,-key}.pem ${node}:
done
