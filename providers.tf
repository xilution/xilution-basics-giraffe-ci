provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.client_aws_account}:role/xilution-developer-role"
  }
  region = "us-east-1"
  version = "2.41.0"
}

provider "null" {
  version = "2.1"
}
