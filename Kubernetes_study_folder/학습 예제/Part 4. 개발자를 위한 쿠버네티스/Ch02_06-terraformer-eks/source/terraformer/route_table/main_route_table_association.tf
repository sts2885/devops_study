resource "aws_main_route_table_association" "tfer--vpc-002D-0a3caf85516294a72" {
  route_table_id = "${data.terraform_remote_state.local.outputs.aws_route_table_tfer--rtb-002D-06b7bf0f10544b5f2_id}"
  vpc_id         = "vpc-0a3caf85516294a72"
}

resource "aws_main_route_table_association" "tfer--vpc-002D-0c3ca77f5dfe4dde1" {
  route_table_id = "${data.terraform_remote_state.local.outputs.aws_route_table_tfer--rtb-002D-0a7b3501f64ff74fe_id}"
  vpc_id         = "vpc-0c3ca77f5dfe4dde1"
}
