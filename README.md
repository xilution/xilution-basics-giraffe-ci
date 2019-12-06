# xilution-aws-account-infrastructure

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)

## Build the CodeBuild Image

```
git clone https://github.com/xilution/xilution-codebuild-docker-images.git
cd xilution-codebuild-docker-images
make build-standard-2.0
```

## Initialize this Repo

```
make submodules
make init
```

## To Verify

Run `make init && make verify`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`


## To Uninstall the infrastructure

Run `make infrastructure-destroy`

