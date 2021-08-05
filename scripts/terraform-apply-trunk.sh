#!/bin/bash -e

currentDir=$(pwd)
cd ./terraform/trunk

terraform apply -no-color -auto-approve ./terraform-plan.txt

cd ${currentDir}
