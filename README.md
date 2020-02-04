# xilution-basics-giraffe-ci

## Prerequisites

1. Clone `https://github.com/xilution/xilution-scripts` and add root directory to your PATH environment variable.
1. Install [Terraform](https://www.terraform.io/)
1. The following environment variables need to be in scope.
    ```
    export XILUTION_ORGANIZATION_ID={Xilution Organization or Sub-organization ID}
    export CLIENT_AWS_ACCOUNT={Client AWS Account ID}
    export CLIENT_AWS_REGION={Client AWS Region}
    export K8S_CLUSTER_NAME=xilution-k8s
    
    ```

    Check the values
    ```
    echo $XILUTION_ORGANIZATION_ID
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
update-xilution-profile.sh $AWS_SHARED_ACCOUNT_ID $AWS_USER_ID $AWS_PROD_ACCOUNT_ID xilution-developer-role xilution-prod {mfa-code}
assume-client-role.sh $CLIENT_AWS_ACCOUNT xilution-developer-role xilution-prod client-profile
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

Run `aws eks update-kubeconfig --name $K8S_CLUSTER_NAME` to update your local kubeconfig file.

## To connect to a client's Kubernetes Dashboard

Reference: https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

* Run `kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')` to retrieve the authentication token.
* Run `kubectl proxy` to start a kubectl proxy.
    * Type `ctrl-c` to stop the kubectl proxy.
* To access the dashboard endpoint, open the following link with a web browser: `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login`.

## To connect to a client's Prometheus

* Get the Prometheus server URL by running these commands in the same shell:
    ```
    export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitoring port-forward $POD_NAME 9090
    
    ```
    * Type `ctrl-c` to stop the kubectl proxy.
* To access the Prometheus web application, open the following link with a web browser: `http://localhost:9090`.

## To connect to a client's Grafana

Reference: https://grafana.com/docs/grafana/latest/guides/getting_started/

* Get the Grafana URL to visit by running these commands in the same shell:
    ```
    export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
    kubectl --namespace monitoring port-forward $POD_NAME 3000
    
    ```
    * Type `ctrl-c` to stop the kubectl proxy.
* To access the Prometheus web application, open the following link with a web browser: `http://localhost:3000`.
    * Username: `admin`.
    * Run `kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo` to see the admin password.

## To Uninstall the infrastructure

Run `make infrastructure-destroy`
