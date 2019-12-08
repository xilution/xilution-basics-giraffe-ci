resource "aws_vpc" "xilution_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "xilution"
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_subnet" "xilution_public_subnet_1" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.xilution_vpc.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "xilution-public-subnet-1"
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_subnet" "xilution_public_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.xilution_vpc.id
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "xilution-public-subnet-2"
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_subnet" "xilution_private_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.xilution_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    Name = "xilution-private-subnet-1"
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_subnet" "xilution_private_subnet_2" {
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.xilution_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    Name = "xilution-private-subnet-2"
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_internet_gateway" "xilution_internet_gateway" {
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_vpn_gateway_attachment" "xilution_vpn_gateway_attachment" {
  depends_on = [aws_internet_gateway.xilution_internet_gateway]
  vpc_id = aws_vpc.xilution_vpc.id
  vpn_gateway_id = aws_internet_gateway.xilution_internet_gateway.id
}

resource "aws_eip" "xilution_elastic_ip" {
  depends_on = [aws_vpn_gateway_attachment.xilution_vpn_gateway_attachment]
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_nat_gateway" "xilution_nat_gateway" {
  allocation_id = aws_eip.xilution_elastic_ip.allocation_id
  subnet_id = aws_subnet.xilution_public_subnet_1.id
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_route_table" "xilution_public_route_table" {
  vpc_id = aws_vpc.xilution_vpc.id
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_route" "xilution_public_route" {
  route_table_id = aws_route_table.xilution_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.xilution_internet_gateway.id
}

resource "aws_route_table_association" "xilution_public_route_table_association_1" {
  route_table_id = aws_route_table.xilution_public_route_table.id
  subnet_id = aws_subnet.xilution_public_subnet_1.id
}

resource "aws_route_table_association" "xilution_public_route_table_association_2" {
  route_table_id = aws_route_table.xilution_public_route_table.id
  subnet_id = aws_subnet.xilution_public_subnet_2.id
}

resource "aws_route_table" "xilution_private_route_table" {
  vpc_id = aws_vpc.xilution_vpc.id
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_route" "xilution_private_route" {
  route_table_id = aws_route_table.xilution_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.xilution_nat_gateway.id
}

resource "aws_route_table_association" "xilution_private_route_table_association_1" {
  route_table_id = aws_route_table.xilution_private_route_table.id
  subnet_id = aws_subnet.xilution_private_subnet_1.id
}

resource "aws_route_table_association" "xilution_private_route_table_association_2" {
  route_table_id = aws_route_table.xilution_private_route_table.id
  subnet_id = aws_subnet.xilution_private_subnet_2.id
}

# TODO - add K8s

# TODO - add NFS
