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

    instance_types = ["t3a.large"]#["m5.xlarge"]
    
    capacity_type = "SPOT"
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
    instance_types = ["m5.xlarge"]
    capacity_type = "SPOT"
    
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
