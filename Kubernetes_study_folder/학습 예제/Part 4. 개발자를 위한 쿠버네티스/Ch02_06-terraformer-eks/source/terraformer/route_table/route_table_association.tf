resource "aws_route_table_association" "tfer--subnet-002D-0b5dde0d0a29e34b3" {
  route_table_id = "${data.terraform_remote_state.local.outputs.aws_route_table_tfer--rtb-002D-0d17b3d0fd9911b93_id}"
  subnet_id      = "subnet-0b5dde0d0a29e34b3"
}

resource "aws_route_table_association" "tfer--subnet-002D-0ec3438c59d9e5ffb" {
  route_table_id = "${data.terraform_remote_state.local.outputs.aws_route_table_tfer--rtb-002D-0d17b3d0fd9911b93_id}"
  subnet_id      = "subnet-0ec3438c59d9e5ffb"
}
