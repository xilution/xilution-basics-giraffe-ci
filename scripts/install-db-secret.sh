#!/bin/bash

WORDPRESS_DB_PASSWORD=$1

cat <<EOF >./secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-pass
  namespace: wordpress
type: Opaque
data:
  password: ${WORDPRESS_DB_PASSWORD}
EOF
kubectl apply -f secrets.yaml
rm -rf secrets.yaml
