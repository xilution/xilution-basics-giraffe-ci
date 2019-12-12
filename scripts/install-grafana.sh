#!/bin/bash

# reference: https://medium.com/@at_ishikawa/install-prometheus-and-grafana-by-helm-9784c73a3e97

helm tiller run tiller -- helm install stable/grafana \
  --name grafana \
  --namespace monitoring \
  --host 127.0.0.1:44134 \
  --tiller-namespace tiller
