#!/bin/bash

key_name=$(uuidgen)

aws ec2 create-key-pair --key-name "$key_name" | jq -r ".KeyMaterial" > ./key.pem

instance_id=$(aws ec2 run-instances --launch-template LaunchTemplateName=xilution-giraffe-"$PIPELINE_ID" --key-name "$key_name" | jq -r ".Instances[0].InstanceId")

state="unknown"
while [[ ! $state =~ ^(running)$ ]]
do
  clear
  state=$(aws ec2 describe-instances --instance-id "${instance_id}" | jq -r ".Reservations[0].Instances[0].State.Name")
  echo "$state"
  sleep 2
done

public_dns_name=$(aws ec2 describe-instances --instance-id "${instance_id}" | jq -r ".Reservations[0].Instances[0].PublicDnsName")

ssh -i ./key.pem ec2-user@"${public_dns_name}"

aws ec2 terminate-instances --instance-ids "${instance_id}"

aws ec2 delete-key-pair --key-name "$key_name"

rm -rf ./key.pem
