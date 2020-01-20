#!/bin/bash

# reference: https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html

kubectl --namespace=kube-system wait --for=condition=Available --timeout=5m apiservices/v1beta1.metrics.k8s.io
helm tiller run tiller -- helm install stable/prometheus \
  --name prometheus \
  --namespace monitoring \
  --set alertmanager.persistentVolume.storageClass="gp2" \
  --set server.persistentVolume.storageClass="gp2" \
  --host 127.0.0.1:44134 \
  --tiller-namespace tiller
