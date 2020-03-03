data "aws_region" "current" {}

data "aws_vpc" "xilution_vpc" {
  filter {
    name = "tag:Name"
    values = [
      "xilution"
    ]
  }
}

data "aws_subnet" "xilution_public_subnet_1" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-public-subnet-1"
    ]
  }
}

data "aws_subnet" "xilution_public_subnet_2" {
  filter {
    name = "tag:Name"
    values = [
      "xilution-public-subnet-2"
    ]
  }
}

data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

locals {
  k8s_cluster_name = "xilution-giraffe-${substr(var.pipeline_id, 0, 8)}"
}

# Network File System

resource "aws_efs_file_system" "nfs" {
  creation_token = "xilution-giraffe-${var.pipeline_id}"
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_security_group" "mount_target_security_group" {
  name = "allow-nfs-in"
  description = "Allow inbound NFS traffic to mount targets"
  vpc_id = data.aws_vpc.xilution_vpc.id
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = [
      data.aws_vpc.xilution_vpc.cidr_block
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_efs_mount_target" "mount_target_1" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id = data.aws_subnet.xilution_public_subnet_1.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}

resource "aws_efs_mount_target" "mount_target_2" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id = data.aws_subnet.xilution_public_subnet_2.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}

resource "aws_ssm_parameter" "efs_filesystem_id" {
  name        = "xilution-giraffe-${var.pipeline_id}-efs-filesystem-id"
  description = "A Giraffe Filesystem ID"
  type        = "String"
  value       = aws_efs_file_system.nfs.id
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

# Database

resource "aws_security_group" "mysql_security_group" {
  name = "allow-mysql-in"
  description = "Allow inbound MySQL traffic to RDS Cluster"
  vpc_id = data.aws_vpc.xilution_vpc.id
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    cidr_blocks = [
      data.aws_vpc.xilution_vpc.cidr_block
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "wordpress-rds-cluster-${var.organization_id}"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.03.2"
  master_username = var.master_username
  master_password = base64decode(var.master_password)
  backup_retention_period = 1
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  skip_final_snapshot = true
  vpc_security_group_ids = [
    aws_security_group.mysql_security_group.id
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count = "2"
  identifier = "wordpress-rds-instance-${var.organization_id}-${count.index}"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.03.2"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class = "db.t2.small"
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name = "wordpress-rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.xilution_public_subnet_1.id,
    data.aws_subnet.xilution_public_subnet_2.id
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_ssm_parameter" "efs_filesystem_id" {
  name        = "xilution-giraffe-${var.pipeline_id}-rds-cluster-endpoint"
  description = "A Giraffe RDS Cluster Endpoint"
  type        = "String"
  value       = aws_rds_cluster.aurora.endpoint
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

# Kubernetes

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "v7.0.1"
  cluster_name = local.k8s_cluster_name
  cluster_version = "1.14"
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
      instance_type = "t3.medium"
      autoscaling_enabled = true
      protect_from_scale_in = false
      asg_max_size = 4
      asg_min_size = 1
      asg_desired_capacity = 2
      tags = [
        {
          key = "xilution_organization_id"
          value = var.organization_id
          propagate_at_launch = true
          xilution_organization_id = var.organization_id
          originator = "xilution.com"
        }
      ]
    }
  ]
  # Needed for Container Insights
  workers_additional_policies = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
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
    command = "/bin/bash ${path.module}/scripts/install-namespaces.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-efs-csi-driver.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-efs-persistent-volume.sh ${aws_efs_file_system.nfs.id}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-metrics-server.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-kubernetes-dashboard.sh"
  }
  provisioner "local-exec" {
    # Allow time for the Kubernetes to warm up before using Helm.
    # Addresses the following error taken when executing the next step.
    # Error: Could not get apiVersions from Kubernetes: unable to retrieve the complete list of server APIs: metrics.k8s.io/v1beta1: the server is currently unable to handle the request
    command = "sleep 30"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-container-insights.sh ${data.aws_region.current.name} ${local.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-cluster-autoscaler.sh ${data.aws_region.current.name} ${local.k8s_cluster_name}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-regcred-secret.sh ${var.docker_username} ${var.docker_password}"
    on_failure = "continue"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-db-secret.sh ${var.master_password}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-db-config-map.sh ${var.master_username} ${aws_rds_cluster.aurora.endpoint}"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-wp-persistent-volumn-claim.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-nginx-ingress-controller.sh"
  }
}

# Metrics

resource "aws_lambda_permission" "allow-giraffe-cloudwatch-every-ten-minute-event-rule" {
  action = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.metrics-reporter-lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.giraffe-cloudwatch-every-ten-minute-event-rule.arn
}

resource "aws_cloudwatch_event_rule" "giraffe-cloudwatch-every-ten-minute-event-rule" {
  name = "giraffe-${var.pipeline_id}-cloudwatch-event-rule"
  schedule_expression = "rate(10 minutes)"
  role_arn = data.aws_iam_role.cloudwatch-events-rule-invocation-role.arn
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_cloudwatch_event_target" "giraffe-cloudwatch-event-target" {
  rule = aws_cloudwatch_event_rule.giraffe-cloudwatch-every-ten-minute-event-rule.name
  arn = data.aws_lambda_function.metrics-reporter-lambda.arn
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
  dashboard_name = "xilution-giraffe-${var.pipeline_id}-dashboard"

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
