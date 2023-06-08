#이게 "클러스터" 보안그룹이라
#마스터도 포함되는지 워커만인지를 모르겠네?
#일단 워커만 넣고 나중에 보자.

#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
#공홈에서는 보안그룹 다열어주라는데? 이게 무슨 개똥같은 소리야?
#진짜로 이게 정설이고 나머지가
#억지로 블랙박스를 열어서 막는 행위인듯
#=> 나중에 유지보수 문제 터지는 거지
# 이를 어쩐다... 일단 내일 이어서가자

resource "aws_security_group" "test-sg-eks-cluster" {
    name = "test-sg-eks-cluster"
    description = "security_group for test-eks-cluster"
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "test-sg-eks-cluster"
    }
}

resource "aws_security_group_rule" "kubelet_api" {
    security_group_id = aws_security_group.test-sg-eks-cluster.id
    type = "ingress"
    description = "kubelet_api port"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "test-sg-eks-cluster-egress" {

    security_group_id = aws_security_group.test-sg-eks-cluster.id
    type = "egress"
    description = "egress secutiry_group_rule for test-eks-cluster"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}


variable "kubelet_api_port" {
    type = number
    default = 10250
}

variable "node_port_from" {
    type = number
    default = 30000
}

variable "node_port_to" {
    default = 32767
}

variable "ssh_port" {
    default = 22
} 
variable "http_port" {
    default = 80
}
variable "server_port" {
    default = 8080
}
variable "https_port" {
    default = 443
}

#그러고 보니까 flannel인지 모르네? udp 포트도 모르네?
#검색해서 넣어야 게쎈?
#variable "f"











