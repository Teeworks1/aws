#security group to allow ssh from specific ip
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "AllowSSH"
  }
}


# Define a Security Group
resource "aws_security_group" "dns_sg" {
  name        = "dns_security_group"
  description = "Allow DNS inbound traffic"
  vpc_id      = aws_vpc.example.id # Replace with your VPC ID or reference

  # Optional: Default Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Ingress rule for DNS (UDP) on port 53
resource "aws_vpc_security_group_ingress_rule" "allow_dns_udp" {
  for_each          = toset(["0.0.0.0/0", "::/0"]) # Allows from any IPv4 and IPv6 source
  security_group_id = aws_security_group.dns_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow inbound UDP DNS"
}

# Ingress rule for DNS (TCP) on port 53
resource "aws_vpc_security_group_ingress_rule" "allow_dns_tcp" {
  for_each          = toset(["0.0.0.0/0", "::/0"]) # Allows from any IPv4 and IPv6 source
  security_group_id = aws_security_group.dns_sg.id
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow inbound TCP DNS"
}
