#!/bin/bash

# reference: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/

DOCKER_USERNAME=$1
DOCKER_PASSWORD=$2

kubectl create secret docker-registry regcred \
  --namespace wordpress \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username="${DOCKER_USERNAME}" \
  --docker-password="${DOCKER_PASSWORD}"
