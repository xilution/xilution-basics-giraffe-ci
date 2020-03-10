clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="xilution_aws_account=$(XILUTION_AWS_ACCOUNT)" \
		-var="xilution_aws_region=$(XILUTION_AWS_REGION)" \
		-var="xilution_environment=$(XILUTION_ENVIRONMENT)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-var="client_aws_region=$(CLIENT_AWS_REGION)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="xilution_aws_account=$(XILUTION_AWS_ACCOUNT)" \
		-var="xilution_aws_region=$(XILUTION_AWS_REGION)" \
		-var="xilution_environment=$(XILUTION_ENVIRONMENT)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-var="client_aws_region=$(CLIENT_AWS_REGION)" \
		-auto-approve

init:
	terraform init \
		-backend-config="key=xilution-basics-giraffe/$(PIPELINE_ID)/terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
		-var="pipeline_id=$(PIPELINE_ID)" \
		-var="xilution_aws_account=$(XILUTION_AWS_ACCOUNT)" \
		-var="xilution_aws_region=$(XILUTION_AWS_REGION)" \
		-var="xilution_environment=$(XILUTION_ENVIRONMENT)" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-var="client_aws_region=$(CLIENT_AWS_REGION)"

submodules-init:
	git submodule update --init

submodules-update:
	git submodule update --remote

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email --profile=xilution-prod | /bin/bash
	docker pull $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nPIPELINE_ID=$(PIPELINE_ID)\nXILUTION_AWS_ACCOUNT=$(XILUTION_AWS_ACCOUNT)\nXILUTION_AWS_REGION=$(XILUTION_AWS_REGION)\nXILUTION_ENVIRONMENT=$(XILUTION_ENVIRONMENT)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/docker-19:latest \
		-p client-profile \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt
