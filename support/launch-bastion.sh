#!/bin/bash

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

key_name=$(uuidgen)

aws ec2 create-key-pair --key-name "$key_name" | jq -r ".KeyMaterial" > ./key.pem
chmod 0600 ./key.pem

echo Enter Giraffe Pipeline ID:
read -r giraffe_pipeline_id

instance_id=$(aws ec2 run-instances --launch-template LaunchTemplateName=xilution-giraffe-"${giraffe_pipeline_id}" --key-name "$key_name" | jq -r ".Instances[0].InstanceId")

state="unknown"
while [[ ! $state =~ ^(running)$ ]]
do
  clear
  state=$(aws ec2 describe-instances --instance-id "${instance_id}" | jq -r ".Reservations[0].Instances[0].State.Name")
  echo "$state"
  sleep 2
done

public_dns_name=$(aws ec2 describe-instances --instance-id "${instance_id}" | jq -r ".Reservations[0].Instances[0].PublicDnsName")

cat <<EOF >./bastion.yaml
---
client_aws_account_id: ${client_aws_account_id}
client_aws_region: ${client_aws_region}
giraffe_pipeline_id: ${giraffe_pipeline_id}
public_dns_name: ${public_dns_name}
instance_id: ${instance_id}
key_name: ${key_name}
EOF

cat ./bastion.yaml

echo Ready!
