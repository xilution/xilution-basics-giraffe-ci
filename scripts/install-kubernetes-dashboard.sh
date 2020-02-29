#!/bin/bash

# reference: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
cat <<EOF >./eks-admin-service-account.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: eks-admin
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: eks-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: eks-admin
  namespace: kube-system
EOF
kubectl apply -f eks-admin-service-account.yaml
rm -rf eks-admin-service-account.yaml
