# xilution-basics-giraffe-ci

## Prerequisites

1. Install [Terraform](https://www.terraform.io/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
    echo $CLIENT_AWS_ACCOUNT
    ```

## Initialize this Repo

```
make submodules-init
make pull-docker-image
make init
```

## To Verify

Run `make verify`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`

## To Uninstall the infrastructure

Run `make infrastructure-destroy`

