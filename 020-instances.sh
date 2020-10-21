#!/bin/bash

set -euxo pipefail

# get public ip
public=$(gcloud compute addresses describe magicless-ip-address \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

# master nodes
for i in 0 1 2; do
  # first controller gets a static ip
  [ $i = 0 ] && addr_arg="--address $public" || addr_arg=""
  gcloud compute instances create controller-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image=ubuntu-2004-focal-v20201014 \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-2 \
    --private-network-ip 10.254.254.10$i \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet magicless-subnet \
    --tags magicless,controller $addr_arg
done


# worker nodes
for i in 0 1 2; do
  gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image=ubuntu-2004-focal-v20201014 \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=192.168.1${i}.0/24 \
    --private-network-ip 10.254.254.20${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet magicless-subnet \
    --tags magicless,worker
done

gcloud compute instances list

