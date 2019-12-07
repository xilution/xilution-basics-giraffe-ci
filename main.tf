resource "aws_vpc" "xilution_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "xilution"
    xilution_organization_id = var.organization_id
  }
}

# TODO - add more network resources

# TODO - add K8s

# TODO - add NFS
