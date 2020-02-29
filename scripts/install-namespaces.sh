#!/bin/bash

cat <<EOF >./namespaces.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: tiller
  labels:
    name: tiller
---
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
  labels:
    name: monitoring
EOF
kubectl apply -f namespaces.yaml
rm -rf namespaces.yaml
