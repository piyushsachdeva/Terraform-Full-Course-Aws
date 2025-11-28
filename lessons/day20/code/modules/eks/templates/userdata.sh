#!/bin/bash
set -ex

# Bootstrap EKS worker node
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_ca} \
  --apiserver-endpoint ${cluster_endpoint}

# Additional userdata
${additional_userdata}
