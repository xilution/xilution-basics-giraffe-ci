#!/bin/bash

FILE_SYSTEM_ID=$1

cat <<EOF >./persistent-volume.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: ${FILE_SYSTEM_ID}
EOF
kubectl apply -f persistent-volume.yaml
rm -rf persistent-volume.yaml
