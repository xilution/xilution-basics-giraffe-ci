#!/bin/bash

# reference: https://docs.aws.amazon.com/eks/latest/userguide/prometheus.html

helm tiller run tiller -- helm install stable/prometheus \
  --name prometheus \
  --namespace monitoring \
  --set alertmanager.persistentVolume.storageClass="gp2",server.persistentVolume.storageClass="gp2" \
  --host 127.0.0.1:44134 \
  --tiller-namespace tiller
