#!/bin/bash

cat <<EOF >./persistent-volumn-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-efs-claim
  namespace: wordpress
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
EOF
kubectl apply -f persistent-volumn-claim.yaml
rm -rf persistent-volumn-claim.yaml
