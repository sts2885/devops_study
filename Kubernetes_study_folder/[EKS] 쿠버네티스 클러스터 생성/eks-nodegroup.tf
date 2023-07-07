#그러고 보니까 겁나 열심히 작성해 놓고 왜 nodegroup security group은 따로 지정 안해주지?
#sg는 만들었는데?
resource "aws_eks_node_group" "eks-nodegroup_1" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = "eks-nodegroup_1"
    node_role_arn = aws_iam_role.iam-role-eks-nodegroup.arn
    subnet_ids = [
        aws_subnet.public_subnet_a.id,
        aws_subnet.public_subnet_c.id
        ]
    #kubectl top 돌려보니까 kubeflow만 딱 깔았을때 m5.xlarge에서 30퍼센트만 메모리를 쓰고 있었음=> 32기가중 1/3 => 10.7기가 제외하면 다 놀음
    #a, i, g => amd, intel, graviton
    #m5.large : 2c 8m => 2개 16기가 정도면 적절할거 같아서 둠
    #m5.xlarge: 4c 16m =>> cpu 별로 쓰지도 않는거 같은데 메모리형으로 쓰고 cpu 코어수를 낮출까?
    #m7시리즈는 다 그래픽카드 달림 m7g, a는 arm,  M6g 인스턴스는 Arm 기반 AWS Graviton2 프로세서로 구동됩니다. 
    #m6 한번 써볼까?
    #m7g.large	0.0816 USD
    #m6g.large	0.077 USD => eks에서 현재 안만들어짐
    #m6i.large	0.096 USD 겁나 비싼데 여기서는 이게 가성비가 좋았다는데? 가격이 그사이에 좀 변했나? https://findstar.pe.kr/2022/08/21/which-instance-type-is-right-for-EKS/
    #m5.large	0.096 USD
    #m6a.large	0.0864 USD => 데이터 처리 때는 이거 쓰고, 학습때는 데스크톱 쓸꺼니까 t3a쓰면 될듯
    #t3a.large	0.0752 USD => 학습, 처리 작업때는 쓰면 안되지만 지금 단계에서는 괜찮을듯 => 써봤는데 작아서 그런가? 주피터가 안만들어짐
    #t3.large	0.0832 USD -> 버그 고치고 다시 써봤는데 안됨.
    #t4g.large	0.0672 USD => 안됨
    #large는 t3a, m5 m6a 전부다 설치가 제대로 안됨 그나마 t3a는 설치는 됐는데 jupyter가 생성이 안됨.
    #ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ#

    #t3.xlarge	0.1664 USD
    #t3a.xlarge	0.1504 USD => 테스트 => 뭐냐 왜 statefulset안되냐? => eksctl 변경 사항 때문에 에러 => 고침 => 정상작동=> 혹시 사이즈 줄여도 될까?
    #t2.xlarge	0.1856 USD

    #m6a.xlarge	0.1728 USD => 실제 돌릴떄 이렇게 하면 될듯 => t3a도 되니까 이거도 되겠지
    #m6i.xlarge	0.192 USD
    #m5.xlarge	0.192 USD
    #m5a.xlarge	0.172 USD

    #mem은 권장 사양이 6c 12g 50gD였던걸 감안하면 다른 타입을 섞어도 될지도
    #c6a.large	0.0765 USD	2	4GiB
    #c6a.xlarge	0.153 USD	4	8GiB

    #All Amazon EKS AMIs don't currently support the g5g and mac families.
    #Arm and non-accelerated Amazon EKS AMIs don't support the g3, g4, inf, and p families.
    #Accelerated Amazon EKS AMIs don't support the a, c, hpc, m, and t families.
    
    instance_types = ["t3a.large"]#["m5.xlarge"]#["t3a.large"]#
    
    capacity_type = "ON_DEMAND"#"SPOT"
    disk_size = 50
    
    labels = {
        "role" = "eks-nodegroup"
    }

    scaling_config {
        desired_size = local.node_size.desired_size
        min_size = local.node_size.min_size
        max_size = local.node_size.max_size
    }

    depends_on = [
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup,
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup-cni,
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup-ecr,
    ]

    tags = {
        "Name" = "${aws_eks_cluster.eks-cluster.name}-worker-node"
    }
}

resource "aws_eks_node_group" "eks-nodegroup_2" {
    cluster_name = aws_eks_cluster.eks-cluster.name
    node_group_name = "eks-nodegroup_2"
    node_role_arn = aws_iam_role.iam-role-eks-nodegroup.arn
    subnet_ids = [
        aws_subnet.public_subnet_a.id,
        aws_subnet.public_subnet_c.id
        ]
    instance_types = ["c6a.xlarge"]#["m5.xlarge"]#["t3a.large"]#
    capacity_type = "ON_DEMAND"#"SPOT"
    
    disk_size= 50

    labels = {
        "role" = "eks-nodegroup"
    }

    scaling_config {
        desired_size = local.node_size.desired_size
        min_size = local.node_size.min_size
        max_size = local.node_size.max_size
    }

    #강의에선 이 부분에 terraformer로 가져온 코드에 의해 launch template을 연결해줬는데
    # 시간이 지나니까 aws에서 포맷이 바뀌어서 autoscaling group 안에 launch template을 private 변수 처럼 써버림
    # blackbox 를 열어서 함부로 쓴 대가. 하면 안되는 짓을 한거임.
    #그래서 여기선 넣지 않고 그냥 node group만 추가하겠음


    depends_on = [
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup,
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup-cni,
        aws_iam_role_policy_attachment.iam-policy-eks-nodegroup-ecr
    ]
    tags = {
        "Name" = "${aws_eks_cluster.eks-cluster.name}-worker-node"
    }
}
