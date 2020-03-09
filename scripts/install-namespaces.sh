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
---
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx
  labels:
    name: ingress-nginx
EOF
kubectl apply -f namespaces.yaml
rm -rf namespaces.yaml
