resource "aws_eks_node_group" "test-eks-nodegroup_1" {
    cluster_name = aws_eks_cluster.test-eks-cluster.name
    node_group_name = "test-eks-nodegroup_1"
    node_role_arn = aws_iam_role.test-iam-role-eks-nodegroup.arn
    subnet_ids = [
        aws_subnet.public_subnet_a.id,
        aws_subnet.public_subnet_c.id
        ]

    instance_types = ["t3a.medium"]
    #이게 좀 무섭긴하네
    #노드 그룹 한번 켜지는데 10분씩 걸리는데
    #이게 꺼진다?
    #진지하게 노드그룹은 내가 켜서 연결시키는게 나을수도 있겠는데?
    #=> 이게 노드 그룹만 이런거고 완성 된 뒤에 노드는 빨리 켜지는듯?
    capacity_type = "SPOT"
    disk_size = 20
    
    labels = {
        "role" = "eks-nodegroup"
    }

    scaling_config {
        desired_size = 1
        min_size = 1
        max_size = 1
    }

    depends_on = [
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup,
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup-cni,
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup-ecr,
    ]

    tags = {
        "Name" = "${aws_eks_cluster.test-eks-cluster.name}-worker-node"
    }
}

resource "aws_eks_node_group" "test-eks-nodegroup_2" {
    cluster_name = aws_eks_cluster.test-eks-cluster.name
    node_group_name = "test-eks-nodegroup_2"
    node_role_arn = aws_iam_role.test-iam-role-eks-nodegroup.arn
    subnet_ids = [
        aws_subnet.public_subnet_a.id,
        aws_subnet.public_subnet_c.id
        ]
    instance_types = ["t3a.medium"]
    capacity_type = "SPOT"
    
    disk_size= 20

    labels = {
        "role" = "eks-nodegroup"
    }

    scaling_config {
        desired_size = 1
        min_size = 1
        max_size = 1
    }

    #강의에선 이 부분에 terraformer로 가져온 코드에 의해 launch template을 연결해줬는데
    # 시간이 지나니까 aws에서 포맷이 바뀌어서 autoscaling group 안에 launch template을 private 변수 처럼 써버림
    # blackbox 를 열어서 함부로 쓴 대가. 하면 안되는 짓을 한거임.
    #그래서 여기선 넣지 않고 그냥 node group만 추가하겠음


    depends_on = [
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup,
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup-cni,
        aws_iam_role_policy_attachment.test-iam-policy-eks-nodegroup-ecr
    ]
    tags = {
        "Name" = "${aws_eks_cluster.test-eks-cluster.name}-worker-node"
    }
}
