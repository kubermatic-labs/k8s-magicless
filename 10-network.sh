#!/bin/bash

### ensure the correct gcp project is set:
# gcloud config list
### if not run
# gcloud projects list
# gcloud config set project PROJECT_ID

gcloud config set compute/region europe-west2
gcloud config set compute/zone europe-west2-a

gcloud compute networks create magicless-vpc --subnet-mode custom

gcloud compute networks subnets create magicless-subnet \
  --network magicless-vpc \
  --range 10.254.254.0/24

# internal traffic between nodes and pods
# we'll also need ipip protocol!
gcloud compute firewall-rules create magicless-internal \
  --action allow --rules all \
  --network magicless-vpc \
  --source-ranges 10.254.254.0/24,192.168.0.0/16
  # --allow tcp,udp,icmp \

# inbound traffic
gcloud compute firewall-rules create magicless-inbound \
  --allow tcp:22,tcp:6443,icmp \
  --network magicless-vpc \
  --source-ranges 0.0.0.0/0

# and let's have one static ip
gcloud compute addresses create magicless-ip-address \
  --region $(gcloud config get-value compute/region)
gcloud compute addresses list --filter="name=('magicless-ip-address')"
