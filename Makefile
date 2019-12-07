clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-auto-approve

init:
	terraform init \
		-backend-config="role_arn=arn:aws:iam::$(CLIENT_AWS_ACCOUNT):role/xilution-developer-role" \
		-backend-config="key=terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table"

submodules:
	git submodule add https://github.com/aws/aws-codebuild-docker-images.git aws-codebuild-docker-images

verify:
	terraform validate

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i xilution/codebuild/standard-2.0 \
		-a ./output \
		-c \
		-e ./properties.txt \
		-s .
	rm -rf ./properties.txt
