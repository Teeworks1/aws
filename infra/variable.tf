# variable "ami_id" {
#   description = "The AMI ID for the EC2 instance"
#   type        = string
# }   

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t3.micro"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  default     = "deployer-key"
}

variable "availability_zone" {
  description = "The availability zone to deploy the instance in"
  type        = string
  default     = "us-east-1a"
}

# variable "subnet_id" {
#   description = "The subnet ID to launch the instance in"
#   type        = string
# }