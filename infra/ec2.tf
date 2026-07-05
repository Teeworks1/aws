#aws ec2 instance module usage
# module "ec2_instance" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name                  = "single-instance"
#   instance_type         = var.instance_type
#   availability_zone     = var.availability_zone
#   ami                   = data.aws_ami.latest.id
#   key_name              = aws_key_pair.example.key_name
#   monitoring            = true
#   subnet_id             = aws_subnet.example.id
#   security_group_vpc_id = aws_security_group.allow_ssh.vpc_id

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo yum update -y
#               sudo yum install -y httpd
#               sudo systemctl start httpd
#               sudo systemctl enable httpd
#               echo '<h1>Welcome to Teeworks Infrastructure - Module</h1>' | sudo tee /var/www/html/index.html
#               EOF

#   tags = merge(
#     {
#       Name = "TestInstance"
#     },
#     local.common_tags
#   )
# }

#aws instance resource
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest.id # Example AMI, replace with a valid one
  instance_type          = var.instance_type
  key_name               = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.example.id

  depends_on = [aws_key_pair.example]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<h1>Welcome to Teeworks Infrastructure</h1>' | sudo tee /var/www/html/index.html"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.ed25519-example.private_key_pem
      host        = self.public_ip
    }

  }
  tags = merge(
    {
      Name = "BastionHost"
    },
    local.common_tags
  )
}

#aws instance resource
resource "aws_instance" "dns" {
  ami                    = data.aws_ami.latest.id # Example AMI, replace with a valid one
  instance_type          = var.instance_type
  key_name               = aws_key_pair.example.key_name
  vpc_security_group_ids = [aws_security_group.dns_sg.id, aws_security_group.allow_ssh.id]
  availability_zone      = var.availability_zone
  subnet_id              = aws_subnet.example.id

  depends_on = [aws_key_pair.example]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y bind bind-utils

    sed -i 's/listen-on port 53 { 127.0.0.1; };/\/\/listen-on port 53 { 127.0.0.1; };/' /etc/named.conf
    sed -i 's/allow-query     { localhost; };/allow-query     { any; };/' /etc/named.conf

    systemctl enable named
    systemctl start named
  EOF

  tags = merge(
    {
      Name = "DNSHost"
    },
    local.common_tags
  )
}

#bastion host in public subnet for ssh access to private subnet
resource "aws_instance" "test" {
  ami                    = data.aws_ami.latest.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.example.key_name
  monitoring             = true
  subnet_id              = aws_subnet.example2.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, ]

  user_data =  file("${path.module}/scripts/startup-script.sh")

  tags = merge(
    {
      Name = "TestInstance"
    },
    local.common_tags
  )
}
resource " terracurl_http" "example" {
  url = "http://${aws_instance.test.public_ip}:80"
  method = "GET"
  headers = {
    "Content-Type" = "application/json"
  }
  response {
    status_code = 200
  }
  max_retries = 5
  retry_interval = 10
}
#terraform output
#ssh <name of user>@$(terraform output --raw public_ip)
#name of user is essentially the username defined in the tf server configuration
#https://www.youtube.com/watch?v=Xni8GUcWQ_s&t=966s