# DHCP options set for the VPC to use AmazonProvidedDNS for domain name resolution
resource "aws_vpc_dhcp_options" "foo" {
  domain_name                       = "service.consul"
  domain_name_servers               = ["AmazonProvidedDNS"]
  ipv6_address_preferred_lease_time = 1440
  #   ntp_servers                       = ["127.0.0.1"]
  #   netbios_name_servers              = ["127.0.0.1"]
  #   netbios_node_type                 = 2

  tags = {
    Name = "foo-name"
  }
}

# Associate the DHCP options set with the VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.example.id
  dhcp_options_id = aws_vpc_dhcp_options.foo.id
}

#k get pods --show-labels