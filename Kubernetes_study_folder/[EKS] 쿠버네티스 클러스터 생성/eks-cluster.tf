resource "aws_eks_cluster" "eks-cluster" {

    #콘솔에서 손으로 만들었던 custom iam role
    #클러스터 만들기 전에 depends_on이 먼저 선행되어야 한다 라는 뜻
    #결국 이건 자동화가 안된건가?
    #아니네 iam-roles라는 부분에서 만들 수 있음.
    depends_on = [
        aws_iam_role_policy_attachment.iam-policy-eks-cluster,
        aws_iam_role_policy_attachment.iam-policy-eks-cluster-vpc,
    ]
    
    #클러스터 이름(변수에서)
    name = var.cluster_name
    #리소스 주소 arn
    role_arn = aws_iam_role.iam-role-eks-cluster.arn
    version = "1.27"

    #로그를 뭘 남길것인가?
    #control plane이 black box가 되서 못보니까
    #로그를 남겨서 로그를 보는걸로 대체하자.
    enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

    #vpc 정보
    vpc_config {
        security_group_ids = [aws_security_group.eks-cluster-sg.id]

        #강의는 너무 이지모드로 했네, 서브넷 안만들어서 넣을 방법이 없다니
        #목록 읽어와서 변수에 넣어서 넣으면 될텐데
        subnet_ids = [aws_subnet.public_subnet_a.id,
                        aws_subnet.public_subnet_c.id
                    ]
        endpoint_public_access = true
    }
}
