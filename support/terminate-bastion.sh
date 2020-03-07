#!/bin/bash

client_aws_account_id=$(yq r ./bastion.yaml client_aws_account_id)
client_aws_region=$(yq r ./bastion.yaml client_aws_region)
instance_id=$(yq r ./bastion.yaml instance_id)
key_name=$(yq r ./bastion.yaml key_name)

echo Enter MFA Code:
read -r mfa_code

unset AWS_PROFILE
unset AWS_REGION

update-xilution-mfa-profile.sh "$AWS_SHARED_ACCOUNT_ID" "$AWS_USER_ID" "${mfa_code}"

assume-client-role.sh "$AWS_PROD_ACCOUNT_ID" "$client_aws_account_id" xilution-developer-role xilution-developer-role xilution-prod client-profile

export AWS_PROFILE=client-profile
export AWS_REGION=$client_aws_region


aws ec2 terminate-instances --instance-ids "${instance_id}"

aws ec2 delete-key-pair --key-name "${key_name}"

rm -rf ./key.pem ./bastion.yaml
