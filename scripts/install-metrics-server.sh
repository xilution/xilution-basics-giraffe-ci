#!/bin/bash

# reference: https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

DOWNLOAD_URL=$(curl --silent "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases/latest" | jq -r .tarball_url)
DOWNLOAD_VERSION=$(grep -o '[^/v]*$' <<< "$DOWNLOAD_URL")
curl -Ls "$DOWNLOAD_URL" -o metrics-server-"$DOWNLOAD_VERSION".tar.gz
mkdir metrics-server-"$DOWNLOAD_VERSION"
tar -xzf metrics-server-"$DOWNLOAD_VERSION".tar.gz --directory metrics-server-"$DOWNLOAD_VERSION" --strip-components 1
kubectl apply -f metrics-server-"$DOWNLOAD_VERSION"/deploy/1.8+/
rm -rf metrics-server-"$DOWNLOAD_VERSION".tar.gz metrics-server-"$DOWNLOAD_VERSION"
