#!/bin/bash

# reference: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md

AWS_REGION=$1
CLUSTER_NAME=$2

kubectl --namespace=kube-system wait --for=condition=Available --timeout=5m apiservices/v1beta1.metrics.k8s.io
helm tiller run tiller -- helm install stable/cluster-autoscaler \
  --set rbac.create=true \
  --set cloudProvider="aws" \
  --set awsRegion="${AWS_REGION}" \
  --set autoDiscovery.clusterName="${CLUSTER_NAME}" \
  --set autoDiscovery.enabled=true \
  --host 127.0.0.1:44134 \
  --tiller-namespace tiller
