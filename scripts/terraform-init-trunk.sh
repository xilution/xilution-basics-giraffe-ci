#!/bin/bash -e

awsAccountId=${CLIENT_AWS_ACCOUNT}
pipelineId=${GIRAFFE_PIPELINE_ID}

currentDir=$(pwd)
cd ./terraform/trunk

terraform init -no-color \
  -backend-config="key=xilution-basics-giraffe/${pipelineId}/terraform.tfstate" \
  -backend-config="bucket=xilution-terraform-backend-state-bucket-${awsAccountId}" \
  -backend-config="dynamodb_table=xilution-terraform-backend-lock-table"

cd ${currentDir}
