resource "aws_route_table" "tfer--rtb-002D-06b7bf0f10544b5f2" {
  vpc_id = "vpc-0a3caf85516294a72"
}

resource "aws_route_table" "tfer--rtb-002D-0a7b3501f64ff74fe" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0d5e1430b8c71578c"
  }

  vpc_id = "vpc-0c3ca77f5dfe4dde1"
}

resource "aws_route_table" "tfer--rtb-002D-0d17b3d0fd9911b93" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0151e8ea935a86b47"
  }

  tags = {
    Name    = "public_rt"
    created = "2023.05.16"
    group   = "sts"
  }

  tags_all = {
    Name    = "public_rt"
    created = "2023.05.16"
    group   = "sts"
  }

  vpc_id = "vpc-0a3caf85516294a72"
}
