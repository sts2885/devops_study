

#vpc 생성
resource "aws_vpc" "kube_vpc" {
    #cidr_block = "10.1.0.0/16"
    #강의에서 쓴 대역을 따라감 => 이제좀 익숙하니까 작은걸로 바꾸자.
    cidr_block = "172.31.50.0/24"

    tags = {
        Name = "kube_vpc"
    }

    tags_all = {
        Name = "kube_vpc"
    }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "100.64.0.0/16"

    #써보니까 현재 이 resource에는 tag라는항목이 존재 안하는듯
    #tags = {
    #    Name = "eks pod network"
    #}
}

#public subnet 생성
resource "aws_subnet" "public_subnet_a" {

    depends_on = [
        aws_vpc.kube_vpc
    ]

    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "172.31.50.0/26"

    availability_zone = "us-east-1a"

    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_a"
        #여기에 lb 생성 태그 들어가야 되는 거 아니냐?

        #eks 클러스터, 노드 자동 생성에 필요한 태그 <- 그러니까 여기에는 사실상 필요없긴 함.
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb  controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
    #하위 항목에 다 달린다는게 인스턴스나 igw나 nat 같은거 말하는건가?
    tags_all = {
        Name = "public_subnet_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "public_subnet_c" {

    depends_on = [
        aws_vpc.kube_vpc
    ]

    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "172.31.50.64/26"

    availability_zone = "us-east-1c"

    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }

    tags_all = {
        Name = "public_subnet_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}


#worker를 private에, private subnet 생성
resource "aws_subnet" "private_subnet_a" {

    depends_on = [
        aws_vpc.kube_vpc
    ]

    vpc_id = aws_vpc.kube_vpc.id
    #cidr_block = "10.1.0.0/24"
    cidr_block = "172.31.50.128/26"

    availability_zone = "us-east-1a"

    #map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }

    #이거 있어야 하위 항목에 전부 다 태그달린다는데 정확히 어떤의민지 체감이 잘 안됨
    tags_all = {
        Name = "public_subnet_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "private_subnet_c" {
    depends_on = [
        aws_vpc.kube_vpc
    ]

    vpc_id = aws_vpc.kube_vpc.id
    #cidr_block = "10.1.1.0/24"
    cidr_block = "172.31.50.192/26"
    availability_zone = "us-east-1c"
    #az가 같아야 pv mount가능 <= 이제 필요없으니까 돌아간다.
    #availability_zone = "us-east-1a"
    
    #map_public_ip_on_launch = true

    tags = {
        Name = "private_subnet_c"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }

    tags_all = {
        Name = "public_subnet_c"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "private_subnet_eks_pods_a" {
    depends_on = [
        aws_vpc.kube_vpc,
        aws_vpc_ipv4_cidr_block_association.secondary_cidr
    ]

    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "100.64.0.0/19"
    
    #뭐야. 가만히 보니까 강사 코드에는 az 명시가 안되어 있는데?
    #공유한 코드에는 명시가 되어 있는데 강의에는 없는데? 지금부터 추가하나?
    #아~ 나중에 하네

    availability_zone = "us-east-1a"
    
    map_public_ip_on_launch = true

    tags = {
        Name = "private_subnet_eks_pods_a"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }

    tags_all = {
        Name = "private_subnet_eks_pods_a"        
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}

resource "aws_subnet" "private_subnet_eks_pods_c" {
    depends_on = [
        aws_vpc.kube_vpc,
        aws_vpc_ipv4_cidr_block_association.secondary_cidr
    ]
    #강의에서는 vpc id 하드코딩된 값을 그냥 복붙하는데
    #이러면 문제가 뭐냐면 terraform destroy하고 다시 만들면
    #손으로 또 다시 복붙해야 됨
    #안그러면 안돌아감
    #또, 인프라를 새로 만들어서 blue green deploy를 하고 싶다.
    # 그래서 같은 코드에서 모듈만 적용해서 새로 띄우는데
    # 새로 띄운 모듈이 같은 subnet을 바라보고 있다? <- 의도한게 아니라면, 에러 발생의 소지까지 생김
    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "100.64.32.0/19"

    availability_zone = "us-east-1c"
    #az가 같아야 pv mount가능
    #availability_zone = "us-east-1a"

    map_public_ip_on_launch = true

    tags = {
        Name = "private_subnet_eks_pods_c"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }

    tags_all = {
        Name = "private_subnet_eks_pods_c"
        #eks 클러스터, 노드 자동생성에 필요한 태그
        "kubernetes.io/cluster/eks-cluster" = "shared"
        #lb controller service account를 생성하기 위한 태그
        "kubernetes.io/role/elb" = 1
    }
}


#igw
resource "aws_internet_gateway" "kube_igw" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "kube_igw"
    }
}

#nat
resource "aws_eip" "nat_ip" {
    vpc = true

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_nat_gateway" "kube_nat" {
    allocation_id = aws_eip.nat_ip.id
    subnet_id = aws_subnet.public_subnet_a.id

    tags = {
        Name = "kube_nat"
    }

    depends_on = [aws_internet_gateway.kube_igw]
}


#route table
#안 나눠도 되지만 정석에 따라 rt를 나누겠음.
resource "aws_route_table" "public_rt_a" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "public_rt_a"
    }

    tags_all = {
        Name = "public_rt_a"
    }
}

resource "aws_route_table" "public_rt_c" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "public_rt_c"
    }

    tags_all = {
        Name = "public_rt_c"
    }
}

resource "aws_route_table" "private_rt_a" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "private_rt_a"
    }

    tags_all = {
        Name = "private_rt_a"
    }
}

resource "aws_route_table" "private_rt_c" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "private_rt_c"
    }

    tags_all = {
        Name = "private_rc_c"
    }
}

resource "aws_route_table" "private_rt_eks_pods_a" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "private_rt_eks_pods_a"
    }
    tags_all = {
        Name = "private_rt_eks_pods_a"
    }
}

resource "aws_route_table" "private_rt_eks_pods_c" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "private_rt_eks_pods_c"
    }
    tags_all = {
        Name = "private_rt_eks_pods_c"
    }
}




#subnet to rt 연결
resource "aws_route_table_association" "public_rt_a_association" {
    subnet_id = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.public_rt_a.id
}

resource "aws_route_table_association" "public_rt_c_association" {
    subnet_id = aws_subnet.public_subnet_c.id
    route_table_id = aws_route_table.public_rt_c.id
}

#private subnet to rt 연결
resource "aws_route_table_association" "private_rt_a_association" {
    subnet_id = aws_subnet.private_subnet_a.id
    route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_rt_c_association" {
    subnet_id = aws_subnet.private_subnet_c.id
    route_table_id = aws_route_table.private_rt_c.id
}

#pod subnet to rt 연결
resource "aws_route_table_association" "private_rt_eks_pods_a_association" {
    subnet_id = aws_subnet.private_subnet_eks_pods_a.id
    route_table_id = aws_route_table.private_rt_eks_pods_a.id
}

resource "aws_route_table_association" "private_rt_eks_pods_c_association" {
    subnet_id = aws_subnet.private_subnet_eks_pods_c.id
    route_table_id = aws_route_table.private_rt_eks_pods_c.id
}


#rt igw 연결
resource "aws_route" "public_rt_a_igw_connect" {
    route_table_id = aws_route_table.public_rt_a.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
}

resource "aws_route" "public_rt_c_igw_connect" {
    route_table_id = aws_route_table.public_rt_c.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
}

#rt nat 연결
resource "aws_route" "private_rt_a_nat_connect" {
    route_table_id = aws_route_table.private_rt_a.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kube_nat.id
}

resource "aws_route" "private_rt_c_nat_connect" {
    route_table_id = aws_route_table.private_rt_c.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kube_nat.id
}

#pod 쪽
resource "aws_route" "private_rt_eks_pods_a_nat_connect" {
    route_table_id = aws_route_table.private_rt_eks_pods_a.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kube_nat.id
}

resource "aws_route" "private_rt_eks_pods_c_nat_connect" {
    route_table_id = aws_route_table.private_rt_eks_pods_c.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kube_nat.id
}


#resource "aws_route" "public_rt_eks_pods_a_igw_connect" {
#    route_table_id = aws_route_table.public_rt_eks_pods_a.id
#    destination_cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.kube_igw.id
#}

#resource "aws_route" "public_rt_eks_pods_c_igw_connect" {
#    route_table_id = aws_route_table.public_rt_eks_pods_c.id
#    destination_cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.kube_igw.id
#}
