resource "aws_internet_gateway" "tfer--igw-002D-0151e8ea935a86b47" {
  tags = {
    Name    = "kube_igw"
    created = "2023.05.16"
    group   = "sts"
  }

  tags_all = {
    Name    = "kube_igw"
    created = "2023.05.16"
    group   = "sts"
  }

  vpc_id = "vpc-0a3caf85516294a72"
}

resource "aws_internet_gateway" "tfer--igw-002D-0d5e1430b8c71578c" {
  vpc_id = "vpc-0c3ca77f5dfe4dde1"
}
