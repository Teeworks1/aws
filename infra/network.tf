#VPC, Subnet, Internet Gateway, NAT Gateway, Route Table, and Route Table Association resources for AWS infrastructure setup using Terraform.
resource "aws_vpc" "example" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  #   enable_dns_support                   = true
  #   enable_network_address_usage_metrics = true
  tags = {
  Name = "example VPC" }
}

#internet gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.example.id

  tags = {
  Name = "gw Internet" }
}

# pubic subnet creation in default vpc
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  tags                    = local.common_tags
}

# private subnet creation in default vpc
resource "aws_subnet" "example2" {
  vpc_id                          = aws_vpc.example.id
  cidr_block                      = "10.0.2.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.example.ipv6_cidr_block, 8, 0)
  availability_zone               = "us-east-1b"
  assign_ipv6_address_on_creation = true

  tags = local.common_tags
}

#network interface for bastion host
resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.example2.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow_ssh.id]

  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
  tags = {
    Name = "TestENI"
  }
}

#NAT Gateway for private subnet  (#pls also deploy NAT instance and test HA using script for resilience and failover)
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.example.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_egress_only_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "main"
  }
}
#AWS Elastic IP for NAT Gateway
resource "aws_eip" "example" {
  domain = "vpc"

  tags = {
    Name = "gw EIP"
  }
}

#Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

#Route table association for public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.public.id
}

#Route table for private subnet with NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }
}

#Route table association for private subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.example2.id
  route_table_id = aws_route_table.private.id
}

