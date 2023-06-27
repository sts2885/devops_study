#이게 "클러스터" 보안그룹이라
#마스터도 포함되는지 워커만인지를 모르겠네?
#일단 워커만 넣고 나중에 보자.

#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
#공홈에서는 보안그룹 다열어주라는데? 이게 무슨 개똥같은 소리야?
#진짜로 이게 정설이고 나머지가
#억지로 블랙박스를 열어서 막는 행위인듯
#=> 나중에 유지보수 문제 터지는 거지
# 이를 어쩐다... 일단 내일 이어서가자


#기본적으로는 eks에서 어떤 포트를 사용하는지 공개하지 않고 있다.
#그냥 쿠버네티스 쓰는거 그대로 쓰기에도 설정이나,
# 들어가는 에드온이 달라지는 순간 그대로 먹통이 될테니까
# 공식 가이드가 나오기 전엔 그냥 vpc 대역에 대해서만 열어주는 용도 정도로 사용하자.

#워커노드가 이 vpc 안에 속하긴 한걸까?;;;

#cluster, nodegroup sg
resource "aws_security_group" "test-sg-eks-cluster" {
    name = "test-sg-eks-cluster"
    description = "security_group for test-eks-cluster"
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "test-sg-eks-cluster"
    }
}

resource "aws_security_group_rule" "test-sg-eks-cluster-ingress" {
    security_group_id = aws_security_group.test-sg-eks-cluster.id
    type = "ingress"
    description = "ingress security_group_rule for test-eks-cluster"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
        aws_vpc.kube_vpc.cidr_block,
        aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block,
        "${chomp(data.http.myip.body)}/32"
    ]
    #["0.0.0.0/0"]#
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

#EKS PODs sg
resource "aws_security_group" "test-sg-eks-pods"{
    name = "test-sg-eks-pods"
    description = "sg for test-eks-pods"
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "test-sg-eks-pods"
    }

}

resource "aws_security_group_rule" "test-sg-eks-pods-ingress" {
    security_group_id = aws_security_group.test-sg-eks-pods.id
    type = "ingress"
    description = "ingress sg rule for test-eks-pods"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
        aws_vpc.kube_vpc.cidr_block,
        aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block,
        "${chomp(data.http.myip.body)}/32"
    ]
}

resource "aws_security_group_rule" "test-sg-eks-pods-egress" {
    security_group_id = aws_security_group.test-sg-eks-pods.id
    type = "egress"
    description = "egress sg rule for test eks pods"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}


data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

output "my_ip" {
    value = "${chomp(data.http.myip.body)}/32"
    description = "my ip"
}










