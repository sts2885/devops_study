variable "aws_region" {
    default = "us-east-1"
    #타입 명시 안되어 있으면 string이다.(-강사님)
}

variable "cluster_name" {
    default = "eks-cluster"
    type = string
}

locals {
    #node_size will be deprecated in future
    node_size = yamldecode(file("node_size.yml"))#["max_size"]
    node_size_for_group_1 = yamldecode(file("node_size_for_group_1.yml"))
    node_size_for_group_2 = yamldecode(file("node_size_for_group_2.yml"))
}

/*
variable "desired_size" {
    default = local.node_size.desired_size
    type = number
}

variable "min_size" {
    default = local.node_size.min_size
    type = number
}

variable "max_size" {
    default = local.node_size.max_size
    type = number
}
*/