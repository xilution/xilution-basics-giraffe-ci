#!/bin/bash

WORDPRESS_DB_PASSWORD=$1

cat <<EOF >./db-secrets.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-pass
  namespace: wordpress
type: Opaque
data:
  password: ${WORDPRESS_DB_PASSWORD}
EOF
kubectl apply -f db-secrets.yaml
rm -rf db-secrets.yaml
