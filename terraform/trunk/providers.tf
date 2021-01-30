provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.client_aws_account}:role/xilution-agent-role"
  }
  region  = "us-east-1"
  version = "3.14.1"
}

provider "null" {
  version = "2.1"
}
