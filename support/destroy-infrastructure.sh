#!/bin/bash

echo Enter Client Xilution Organization ID:
read -r client_xilution_organization_id

echo Enter Giraffe Pipeline ID:
read -r giraffe_pipeline_id

echo Enter Client AWS Account ID:
read -r client_aws_account_id

echo Enter Client AWS Region:
read -r client_aws_region

echo Enter MFA Code:
read -r mfa_code

unset AWS_PROFILE
unset AWS_REGION

update-xilution-mfa-profile.sh "$AWS_SHARED_ACCOUNT_ID" "$AWS_USER_ID" "${mfa_code}"

assume-client-role.sh "$AWS_PROD_ACCOUNT_ID" "$client_aws_account_id" xilution-developer-role xilution-developer-role xilution-prod client-profile

export AWS_PROFILE=client-profile
export AWS_REGION=$client_aws_region

export XILUTION_ORGANIZATION_ID=${client_xilution_organization_id}
export PIPELINE_ID=${giraffe_pipeline_id}
export XILUTION_AWS_ACCOUNT=$AWS_PROD_ACCOUNT_ID
export XILUTION_AWS_REGION=us-east-1
export XILUTION_ENVIRONMENT=prod
export CLIENT_AWS_ACCOUNT=${client_aws_account_id}
export CLIENT_AWS_REGION=${client_aws_region}

make init

make infrastructure-destroy
