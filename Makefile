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
		-var="docker_username=nonsense" \
		-var="docker_password=nonsense" \
		-auto-approve

uninstall-prometheus:
	helm tiller run tiller -- helm delete prometheus
	helm tiller run tiller -- helm del --purge prometheus

uninstall-grafana:
	helm tiller run tiller -- helm delete grafana
	helm tiller run tiller -- helm del --purge grafana

init:
	terraform init \
		-backend-config="key=terraform.tfstate" \
		-backend-config="bucket=xilution-terraform-backend-state-bucket-$(CLIENT_AWS_ACCOUNT)" \
		-backend-config="dynamodb_table=xilution-terraform-backend-lock-table" \
		-var="client_aws_account=$(CLIENT_AWS_ACCOUNT)"

submodules-init:
	git submodule update --init

submodules-update:
	git submodule update --remote

verify:
	terraform validate

pull-docker-image:
	aws ecr get-login --no-include-email --profile=xilution-prod | /bin/bash
	docker pull $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest

test-pipeline-infrastructure:
	echo "XILUTION_ORGANIZATION_ID=$(XILUTION_ORGANIZATION_ID)\nCLIENT_AWS_ACCOUNT=$(CLIENT_AWS_ACCOUNT)" > ./properties.txt
	/bin/bash ./aws-codebuild-docker-images/local_builds/codebuild_build.sh \
		-i $(XILUTION_PROD_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/xilution/codebuild/standard-2.0:latest \
		-p client-profile \
		-a ./output/infrastructure \
		-b /codebuild/output/srcDownload/secSrc/buildspecs/buildspec.yaml \
		-c \
		-e ./properties.txt \
		-s . \
		-s buildspecs:./buildspecs/infrastructure
	rm -rf ./properties.txt
