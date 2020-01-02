data "aws_region" "current" {}

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
  vpc_id = aws_vpc.xilution_vpc.id
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

resource "aws_efs_file_system" "nfs" {
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "aws_security_group" "mount_target_security_group" {
  name = "allow-nfs-in"
  description = "Allow inbound NFS traffic to mount targets"
  vpc_id = aws_vpc.xilution_vpc.id
  ingress {
    from_port = 2049
    protocol = "tcp"
    to_port = 2049
    cidr_blocks = [
      aws_vpc.xilution_vpc.cidr_block
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
  subnet_id = aws_subnet.xilution_public_subnet_1.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}

resource "aws_efs_mount_target" "mount_target_2" {
  file_system_id = aws_efs_file_system.nfs.id
  subnet_id = aws_subnet.xilution_public_subnet_2.id
  security_groups = [
    aws_security_group.mount_target_security_group.id
  ]
}


module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = var.k8s_cluster_name
  cluster_version = "1.14"
  subnets = [
    aws_subnet.xilution_public_subnet_1.id,
    aws_subnet.xilution_public_subnet_2.id
  ]
  vpc_id = aws_vpc.xilution_vpc.id
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
  tags = {
    xilution_organization_id = var.organization_id
    originator = "xilution.com"
  }
}

resource "null_resource" "k8s_configure" {
  depends_on = [
    module.eks
  ]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.k8s_cluster_name}"
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
    command = "/bin/bash ${path.module}/scripts/install-grafana.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-prometheus.sh"
  }
  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/scripts/install-cluster-autoscaler.sh ${data.aws_region.current.name} ${var.k8s_cluster_name}"
  }
}

