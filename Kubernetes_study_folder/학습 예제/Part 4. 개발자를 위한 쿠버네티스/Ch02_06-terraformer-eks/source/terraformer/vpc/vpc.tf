resource "aws_vpc" "tfer--vpc-002D-0a3caf85516294a72" {
  assign_generated_ipv6_cidr_block     = "false"
  cidr_block                           = "10.1.0.0/16"
  enable_dns_hostnames                 = "false"
  enable_dns_support                   = "true"
  enable_network_address_usage_metrics = "false"
  instance_tenancy                     = "default"
  ipv6_netmask_length                  = "0"

  tags = {
    Name    = "kube_vpc"
    created = "2023.05.16"
    group   = "sts"
  }

  tags_all = {
    Name    = "kube_vpc"
    created = "2023.05.16"
    group   = "sts"
  }
}

resource "aws_vpc" "tfer--vpc-002D-0c3ca77f5dfe4dde1" {
  assign_generated_ipv6_cidr_block     = "false"
  cidr_block                           = "172.31.0.0/16"
  enable_dns_hostnames                 = "true"
  enable_dns_support                   = "true"
  enable_network_address_usage_metrics = "false"
  instance_tenancy                     = "default"
  ipv6_netmask_length                  = "0"
}
