variable "aws_region" {
    default = "us-east-1"
    #타입 명시 안되어 있으면 string이다.(-강사님)
}

variable "cluster_name" {
    default = "test-eks-cluster"
    type = string
}
