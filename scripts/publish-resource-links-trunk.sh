#!/bin/bash -e

currentDir=$(pwd)
cd ./terraform/trunk

terraform show -json -no-color > ./terraform-output.json

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
publishResourceLinksQueueUrl="https://sqs.us-east-1.amazonaws.com/952573012699/xilution-publish-resource-links-request-queue"
aws sqs send-message --queue-url ${publishResourceLinksQueueUrl} --message-body file://./terraform-output.json

cd ${currentDir}
