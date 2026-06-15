terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#local setup variables
locals {
  common_tags = {
    Team        = "DevOps"
    Environment = "Development"
    Owner       = "teeworks"
  }
}


#data source to get default VPC
# data "aws_vpc" "default" {
#   filter {
#     name   = "isDefault"
#     values = ["true"]

#   }
#   default    = true
#   id         = "vpc-0186c6691f8bafd38"
#   cidr_block = "172.31.0.0/16"

#   # tags = local.setup
# }

#aws key pair for ssh access
resource "aws_key_pair" "example" {
  key_name   = "deployer-key"
  public_key = tls_private_key.ed25519-example.public_key_openssh
}

#tls private key generation
resource "tls_private_key" "ed25519-example" {
  algorithm = "ED25519"
}



#ami data source to get latest amazon linux 2 ami
data "aws_ami" "latest" {
  region      = "us-east-1"
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  tags = local.common_tags
}

output "instance_public_ip" {
  value = aws_instance.test.public_ip
}

output "instance_id" {
  value = aws_instance.test.id
}