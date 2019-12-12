#!/bin/bash

# reference: https://github.com/kubernetes-sigs/aws-efs-csi-driver

kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
