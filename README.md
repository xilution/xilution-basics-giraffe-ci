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

```
{
    "LaunchTemplateData": {
        "EbsOptimized": false,
        "BlockDeviceMappings": [
            {
                "DeviceName": "/dev/xvda",
                "Ebs": {
                    "Encrypted": false,
                    "DeleteOnTermination": true,
                    "SnapshotId": "snap-03a475f314b035167",
                    "VolumeSize": 8,
                    "VolumeType": "gp2"
                }
            }
        ],
        "NetworkInterfaces": [
            {
                "AssociatePublicIpAddress": true,
                "DeleteOnTermination": true,
                "Description": "Primary network interface",
                "DeviceIndex": 0,
                "Groups": [
                    "sg-0050e23e2ac045191"
                ],
                "InterfaceType": "interface",
                "Ipv6Addresses": [],
                "PrivateIpAddresses": [
                    {
                        "Primary": true,
                        "PrivateIpAddress": "10.0.0.135"
                    }
                ],
                "SubnetId": "subnet-03726687d42a6fb96"
            }
        ],
        "ImageId": "ami-0a887e401f7654935",
        "InstanceType": "t2.micro",
        "KeyName": "xilution-beta",
        "Monitoring": {
            "Enabled": false
        },
        "Placement": {
            "AvailabilityZone": "us-east-1a",
            "GroupName": "",
            "Tenancy": "default"
        },
        "DisableApiTermination": false,
        "InstanceInitiatedShutdownBehavior": "stop",
        "UserData": "I2Nsb3VkLWNvbmZpZwpyZXBvX3VwZGF0ZTogdHJ1ZQpyZXBvX3VwZ3JhZGU6IGFsbApydW5jbWQ6Ci0geXVtIGluc3RhbGwgLXkgYW1hem9uLWVmcy11dGlscwotIGFwdC1nZXQgLXkgaW5zdGFsbCBhbWF6b24tZWZzLXV0aWxzCi0geXVtIGluc3RhbGwgLXkgbmZzLXV0aWxzCi0gYXB0LWdldCAteSBpbnN0YWxsIG5mcy1jb21tb24KLSBmaWxlX3N5c3RlbV9pZF8xPWZzLWM1MTk4MjQ1Ci0gZWZzX21vdW50X3BvaW50XzE9L21udC9lZnMvZnMxCi0gbWtkaXIgLXAgIiR7ZWZzX21vdW50X3BvaW50XzF9IgotIHRlc3QgLWYgIi9zYmluL21vdW50LmVmcyIgJiYgZWNobyAiJHtmaWxlX3N5c3RlbV9pZF8xfTovICR7ZWZzX21vdW50X3BvaW50XzF9IGVmcyB0bHMsX25ldGRldiIgPj4gL2V0Yy9mc3RhYiB8fCBlY2hvICIke2ZpbGVfc3lzdGVtX2lkXzF9LmVmcy51cy1lYXN0LTEuYW1hem9uYXdzLmNvbTovICR7ZWZzX21vdW50X3BvaW50XzF9IG5mczQgbmZzdmVycz00LjEscnNpemU9MTA0ODU3Nix3c2l6ZT0xMDQ4NTc2LGhhcmQsdGltZW89NjAwLHJldHJhbnM9Mixub3Jlc3Zwb3J0LF9uZXRkZXYgMCAwIiA+PiAvZXRjL2ZzdGFiCi0gdGVzdCAtZiAiL3NiaW4vbW91bnQuZWZzIiAmJiBlY2hvIC1lICJcbltjbGllbnQtaW5mb11cbnNvdXJjZT1saXciID4+IC9ldGMvYW1hem9uL2Vmcy9lZnMtdXRpbHMuY29uZgotIG1vdW50IC1hIC10IGVmcyxuZnM0IGRlZmF1bHRzCg==",
        "CreditSpecification": {
            "CpuCredits": "standard"
        },
        "CpuOptions": {
            "CoreCount": 1,
            "ThreadsPerCore": 1
        },
        "CapacityReservationSpecification": {
            "CapacityReservationPreference": "open"
        },
        "HibernationOptions": {
            "Configured": false
        }
    }
}
```
