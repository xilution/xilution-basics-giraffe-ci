# xilution-basics-giraffe-ci

## Prerequisites

1. Clone `https://github.com/xilution/xilution-scripts` and add root directory to your PATH environment variable.
1. Install [Terraform](https://www.terraform.io/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export PIPELINE_ID={Giraffe Pipeline ID}
    export XILUTION_AWS_ACCOUNT=$AWS_PROD_ACCOUNT_ID
    export XILUTION_AWS_REGION=us-east-1
    export XILUTION_ENVIRONMENT=prod
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    export CLIENT_AWS_REGION=us-east-1
    export K8S_CLUSTER_NAME={Kubernetes Cluster Name. Ex: xilution-giraffe-eb78c776}
    
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
    echo $PIPELINE_ID
    echo $XILUTION_AWS_ACCOUNT
    echo $XILUTION_AWS_REGION
    echo $XILUTION_ENVIRONMENT
    echo $CLIENT_AWS_ACCOUNT
    echo $CLIENT_AWS_REGION
    echo $K8S_CLUSTER_NAME
    
    ```

## To pull the CodeBuild docker image

Run `make pull-docker-image`

## To init the submodules

Run `make submodules-init`

## To updated the submodules

Run `make submodules-update`

## To access to a client's account

```
unset AWS_PROFILE
unset AWS_REGION
update-xilution-mfa-profile.sh $AWS_SHARED_ACCOUNT_ID $AWS_USER_ID {mfa-code}
assume-client-role.sh $AWS_PROD_ACCOUNT_ID $CLIENT_AWS_ACCOUNT xilution-developer-role xilution-developer-role xilution-prod client-profile
aws sts get-caller-identity --profile client-profile
export AWS_PROFILE=client-profile
export AWS_REGION=$CLIENT_AWS_REGION

```

## Initialize terraform

Run `make init`

## Verify terraform

Run `make verify`

## To Test Pipeline Infrastructure Step

Run `make test-pipeline-infrastructure`

## To access a client's k8s cluster

Note: K8S_CLUSTER_NAME takes the form of "xilution-giraffe-${substr(var.pipeline_id, 0, 8)}"

Run `aws eks update-kubeconfig --name $K8S_CLUSTER_NAME` to update your local kubeconfig file.

## To connect to a client's Kubernetes Dashboard

Reference: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

* Run `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')` to retrieve the authentication token.
* Run `kubectl proxy` to start a kubectl proxy.
    * Type `ctrl-c` to stop the kubectl proxy.
* To access the dashboard endpoint, open the following link with a web browser: `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login`.

## To Uninstall the infrastructure

Run `make infrastructure-destroy`

```
aws ec2 run-instances
```
