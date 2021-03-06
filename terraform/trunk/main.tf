data "aws_region" "current" {}

data "aws_vpc" "xilution_vpc" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-vpc"
    ]
  }
}

data "aws_subnet" "xilution_public_subnet_1" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-public-subnet-1"
    ]
  }
}

data "aws_subnet" "xilution_public_subnet_2" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-public-subnet-2"
    ]
  }
}

data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

# Network File System

resource "aws_efs_file_system" "nfs" {
  creation_token = "xilution-giraffe-${var.giraffe_pipeline_id}"
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

resource "aws_security_group" "mount_target_security_group" {
  name        = "allow-nfs-in"
  description = "Allow inbound NFS traffic to mount targets"
  vpc_id      = data.aws_vpc.xilution_vpc.id
  ingress {
    from_port = 2049
    protocol  = "tcp"
    to_port   = 2049
    cidr_blocks = [
      data.aws_vpc.xilution_vpc.cidr_block
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

resource "aws_efs_mount_target" "mount_target_1" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id      = data.aws_subnet.xilution_public_subnet_1.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}

resource "aws_efs_mount_target" "mount_target_2" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id      = data.aws_subnet.xilution_public_subnet_2.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}

resource "aws_ssm_parameter" "efs_filesystem_id" {
  name        = "xilution-giraffe-${var.giraffe_pipeline_id}-efs-filesystem-id"
  description = "A Giraffe Filesystem ID"
  type        = "String"
  value       = aws_efs_file_system.nfs.id
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

# Kubernetes

locals {
  k8s_cluster_name              = "xilution-giraffe-${substr(var.giraffe_pipeline_id, 0, 8)}"
  k8s_data_transfer_bucket_name = "xilution-giraffe-${substr(var.giraffe_pipeline_id, 0, 8)}-data-transfer"
}

resource "aws_s3_bucket" "k8s_data_transfer_bucket" {
  bucket = local.k8s_data_transfer_bucket_name
}

resource "aws_iam_policy" "k8s_s3_access_policy" {
  name        = "k8s_s3_access_policy"
  path        = "/"
  description = "Kubernetes S3 Access Policy"
  policy      = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "s3:DeleteObject",
                  "s3:GetObject",
                  "s3:ListBucket",
                  "s3:PutObject"
              ],
              "Resource": [
                  "arn:aws:s3:::xilution-*-data-transfer",
                  "arn:aws:s3:::xilution-*-data-transfer/*"
              ]
          }
      ]
  }
  EOF
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "1.13.3"
}

module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "v13.2.0"
  cluster_name           = local.k8s_cluster_name
  cluster_version        = "1.17"
  cluster_create_timeout = "30m"
  # See: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  subnets = [
    data.aws_subnet.xilution_public_subnet_1.id,
    data.aws_subnet.xilution_public_subnet_2.id
  ]
  vpc_id = data.aws_vpc.xilution_vpc.id
  worker_groups = [
    {
      instance_type         = "t3.medium"
      autoscaling_enabled   = true
      protect_from_scale_in = false
      asg_max_size          = 4
      asg_min_size          = 1
      asg_desired_capacity  = 2
      tags = [
        {
          key                      = "xilution_organization_id"
          value                    = var.organization_id
          propagate_at_launch      = true
          xilution_organization_id = var.organization_id
          originator               = "xilution.com"
        }
      ]
    }
  ]
  # Needed for Container Insights
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    aws_iam_policy.k8s_s3_access_policy.arn
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

resource "null_resource" "k8s_configure" {
  depends_on = [
    module.eks
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-namespaces.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-efs-csi-driver.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-efs-persistent-volume.sh ${aws_efs_file_system.nfs.id}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-metrics-server.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-kubernetes-dashboard.sh"
  }
  provisioner "local-exec" {
    # Allow time for the Kubernetes to warm up before using Helm.
    # Addresses the following error taken when executing the next step.
    # Error: Could not get apiVersions from Kubernetes: unable to retrieve the complete list of server APIs: metrics.k8s.io/v1beta1: the server is currently unable to handle the request
    command = "sleep 30"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-container-insights.sh ${data.aws_region.current.name} ${local.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-cluster-autoscaler.sh ${data.aws_region.current.name} ${local.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/../../scripts/install-nginx-ingress-controller.sh"
  }
}

# Support Template

locals {
  user_data = <<-EOF
  #cloud-config
  repo_update: true
  repo_upgrade: all
  runcmd:
  - apt-get -y install amazon-efs-utils
  - apt-get -y install nfs-common
  - mkdir -p /mnt/efs/fs1
  - test -f "/sbin/mount.efs" && echo "${aws_efs_file_system.nfs.id}:/ /mnt/efs/fs1 efs tls,_netdev" >> /etc/fstab || echo "${aws_efs_file_system.nfs.id}.efs.us-east-1.amazonaws.com:/ /mnt/efs/fs1 nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
  - test -f "/sbin/mount.efs" && echo -e "\n[client-info]\nsource=liw" >> /etc/amazon/efs/efs-utils.conf
  - mount -a -t efs,nfs4 defaults
  EOF
}

resource "aws_security_group" "support_launch_template_security_group" {
  name   = "support_launch_template_security_group"
  vpc_id = data.aws_vpc.xilution_vpc.id
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "support_launch_template" {
  name          = "xilution-giraffe-${var.giraffe_pipeline_id}"
  image_id      = "ami-0a887e401f7654935"
  ebs_optimized = false
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = false
      delete_on_termination = true
      volume_size           = 8
      volume_type           = "gp2"
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    device_index                = 0
    security_groups = [
      aws_security_group.support_launch_template_security_group.id
    ]
    subnet_id = data.aws_subnet.xilution_public_subnet_1.id
  }
  instance_type = "t2.micro"
  monitoring {
    enabled = false
  }
  placement {
    tenancy = "default"
  }
  disable_api_termination              = false
  instance_initiated_shutdown_behavior = "stop"
  user_data                            = base64encode(local.user_data)
  credit_specification {
    cpu_credits = "standard"
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

# Metrics

resource "aws_lambda_permission" "allow-giraffe-cloudwatch-every-ten-minute-event-rule" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.metrics-reporter-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.giraffe-cloudwatch-every-ten-minute-event-rule.arn
}

resource "aws_cloudwatch_event_rule" "giraffe-cloudwatch-every-ten-minute-event-rule" {
  name                = "xilution-giraffe-${substr(var.giraffe_pipeline_id, 0, 8)}-cloudwatch-event-rule"
  schedule_expression = "rate(10 minutes)"
  role_arn            = data.aws_iam_role.cloudwatch-events-rule-invocation-role.arn
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}

resource "aws_cloudwatch_event_target" "giraffe-cloudwatch-event-target" {
  rule  = aws_cloudwatch_event_rule.giraffe-cloudwatch-every-ten-minute-event-rule.name
  arn   = data.aws_lambda_function.metrics-reporter-lambda.arn
  input = <<-DOC
  {
    "Environment": "prod",
    "OrganizationId": "${var.organization_id}",
    "ProductId": "${var.product_id}",
    "Duration": 600000,
    "MetricDataQueries": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricStat": {
          "Metric": {
            "Namespace": "AWS/Lambda",
            "MetricName": "Duration",
            "Dimensions": [
              {
                "Name": "FunctionName",
                "Value": "xilution-client-metrics-reporter-lambda"
              }
            ]
          },
          "Period": 60,
          "Stat": "Average",
          "Unit": "Milliseconds"
        }
      }
    ],
    "MetricNameMaps": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricName": "client-metrics-reporter-lambda-duration"
      }
    ]
  }
  DOC
}

# Dashboards

resource "aws_cloudwatch_dashboard" "giraffe-cloudwatch-dashboard" {
  dashboard_name = "xilution-giraffe-${substr(var.giraffe_pipeline_id, 0, 8)}-dashboard"

  dashboard_body = <<-EOF
  {
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-012345"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "EC2 Instance CPU"
        }
      },
      {
        "type": "text",
        "x": 0,
        "y": 7,
        "width": 3,
        "height": 3,
        "properties": {
          "markdown": "Hello world"
        }
      }
    ]
  }
  EOF
}
