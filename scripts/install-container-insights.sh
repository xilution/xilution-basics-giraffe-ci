#!/bin/bash

# reference: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html

AWS_REGION=$1
CLUSTER_NAME=$2
DOWNLOAD_URL=https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml

curl ${DOWNLOAD_URL} | sed "s/{{cluster_name}}/${CLUSTER_NAME}/;s/{{region_name}}/${AWS_REGION}/" | kubectl apply -f -
