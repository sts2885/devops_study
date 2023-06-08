resource "aws_eks_node_group" "test-eks-nodegroup" {
    cluster_name = aws_eks_cluster.test-eks-cluster.name
    node_group_name = "test-eks-nodegroup"
    node_role_arn = aws_iam_role.test-iam-role-eks-nodegroup.arn
    subnet_ids = [aws_subnet.public_subnet_a.id,
                    aws_subnet.public_subnet_c.id
    ]

    instance_types = ["t3a.medium"]
    #이게 좀 무섭긴하네
    #노드 그룹 한번 켜지는데 10분씩 걸리는데
    #이게 꺼진다?
    #진지하게 노드그룹은 내가 켜서 연결시키는게 나을수도 있겠는데?
    capacity_type = "SPOT"
    disk_size = 20
    
    labels = {
        "role" = "eks-nodegroup"
    }

    scaling_config {
        desired_size = 2
        min_size = 1
        max_size = 3
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