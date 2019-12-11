# xilution-aws-account-infrastructure

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_GITHUB_TOKEN=$GITHUB_TOKEN
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    ```

    Check the values
    ```
    echo $XILUTION_GITHUB_TOKEN
    echo $XILUTION_ORGANIZATION_ID
    echo $CLIENT_AWS_ACCOUNT
    ```

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

