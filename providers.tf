provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.client_aws_account}:role/xilution-developer-role"
  }
  version = "2.41.0"
}
