#!/bin/bash

WORDPRESS_USERNAME=$1
WORDPRESS_DB_HOST=$2

cat <<EOF >./config-map.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: wordpress
data:
  host: ${WORDPRESS_DB_HOST}
  port: "3306"
  user: ${WORDPRESS_USERNAME}
EOF
kubectl apply -f config-map.yaml
rm -rf config-map.yaml
