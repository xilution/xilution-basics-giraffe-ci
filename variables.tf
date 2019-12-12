variable "organization_id" {
  type = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
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

variable "master_username" {
  type = string
  description = "The Database Username"
}

variable "master_password" {
  type = string
  description = "The Database Password"
}
