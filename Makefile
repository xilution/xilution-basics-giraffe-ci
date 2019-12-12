clean:
	rm -rf .terraform properties.txt

build:
	@echo "nothing to build"

infrastructure-plan:
	terraform plan \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
        -var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

infrastructure-destroy:
	terraform destroy \
		-var="organization_id=$(XILUTION_ORGANIZATION_ID)" \
        -var="client_aws_account=$(CLIENT_AWS_ACCOUNT)" \
		-auto-approve

init:
	terraform init \
		-backend-config="role_arn=arn:aws:iam::$(CLIENT_AWS_ACCOUNT):role/xilution-developer-role" \
		-backend-config="key=terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
        -var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

submodules-init:
	git submodule update --init

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email | /bin/bash
	docker pull $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest

test-pipeline-infrastructure:
	echo "XILUTION_GITHUB_TOKEN=$(XILUTION_GITHUB_TOKEN)\nXILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-a ./output \
		-c \
		-e ./properties.txt \
		-s . \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt
