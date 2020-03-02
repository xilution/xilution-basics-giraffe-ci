#!/bin/bash

# reference: https://kubernetes.github.io/ingress-nginx/deploy/#aws
#            https://itnext.io/save-on-your-aws-bill-with-kubernetes-ingress-148214a79dcb

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.30.0/deploy/static/provider/aws/service-nlb.yaml
