#!/bin/bash

# reference: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

DOCKER_USERNAME=$1
DOCKER_PASSWORD=$2

docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" https://index.docker.io/v1/
ENCODED_DOCKER_CONFIG_JSON=$(base64 ~/.docker/config.json)
cat <<EOF >./docker-secrets.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: regcred
  namespace: wordpress
data:
  .dockerconfigjson: "${ENCODED_DOCKER_CONFIG_JSON}"
type: kubernetes.io/dockerconfigjson
EOF
kubectl apply -f docker-secrets.yaml
rm -rf docker-secrets.yaml
