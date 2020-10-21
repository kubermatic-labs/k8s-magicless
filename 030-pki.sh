#!/bin/bash
#
# cfssl available per:
# * `go get github.com/cloudflare/cfssl/cmd/{cfssl,cfssljson}` [needs golang-1.11 + git]
# * package from ubuntu-18.04 (`golang-cfssl`)

set -euxo pipefail

. ./func.sh

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": { "algo": "rsa", "size": 2048 },
  "names": [
    {
      "C": "DE",
      "L": "Hamburg",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Hamburg"
    }
  ]
}
EOF
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "720h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "720h"
      }
    }
  }
}
EOF

# cert creation helper
# arguments: CN filename group SANs
mkcert() {
  cn="$1" ; shift
  filename="$1" ; shift
  group="$1" ; shift
  sans="$1" ; shift

  cfssl gencert \
    -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes \
    -hostname=${sans} \
    <(cat <<EOF
      {
        "CN": "$cn",
        "key": { "algo": "rsa", "size": 2048 },
        "names": [
          {
            "C": "DE",
            "L": "Hamburg",
            "O": "$group",
            "OU": "Kubernetes The Hard Way",
            "ST": "Hamburg"
          }
        ]
      }
EOF
     ) | cfssljson -bare ${filename}
}

# admin user client cert:
# (CN filename group SANs)
mkcert admin admin system:masters ""

# workers
mkcert system:node:worker-0 worker-0 system:nodes $( node_sans worker-0 )
mkcert system:node:worker-1 worker-1 system:nodes $( node_sans worker-1 )
mkcert system:node:worker-2 worker-2 system:nodes $( node_sans worker-2 )

mkcert system:kube-controller-manager kube-controller-manager system:kube-controller-manager ""
mkcert system:kube-proxy kube-proxy system:node-proxier ""
mkcert system:kube-scheduler kube-scheduler system:kube-scheduler ""
mkcert service-accounts service-account Kubernetes ""

# and finally, apiserver:
mkcert kubernetes kubernetes system:masters 10.32.0.1,kubernetes.default,127.0.0.1,10.254.254.100,10.254.254.101,10.254.254.102,$(public_ip)
