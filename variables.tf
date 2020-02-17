variable "organization_id" {
  type = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "product_id" {
  type = string
  description = "The Product ID"
  default = "2ef2593165b143a9b14bc393e6ce90d9"
}

variable "pipeline_id" {
  type = string
  description = "The Pipeline ID"
}

variable "xilution_aws_account" {
  type = string
  description = "The Xilution AWS Account ID"
}

variable "xilution_aws_region" {
  type = string
  description = "The Xilution AWS Region"
}

variable "xilution_environment" {
  type = string
  description = "The Xilution Environment"
}

variable "client_aws_account" {
  type = string
  description = "The Xilution Client AWS Account ID"
}

variable "k8s_cluster_name" {
  type = string
  description = "The Kubernetes Cluster Name"
  default = "xilution-k8s"
}
