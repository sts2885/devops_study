

#### EFS Security Group ####

resource "aws_security_group" "efs-sg" {
  description = "EFS security group"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "2049"
    protocol    = "tcp"
    self        = "false"
    to_port     = "2049"
  }

  name   = "efs-sg"
  vpc_id = aws_vpc.kube_vpc.id
}

#https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
#기본적으로는 eks에서 어떤 포트를 사용하는지 공개하지 않고 있다.
#그냥 쿠버네티스 쓰는거 그대로 쓰기에도 설정이나,
# 들어가는 에드온이 달라지는 순간 그대로 먹통이 될테니까
# 공식 가이드가 나오기 전엔 그냥 vpc 대역에 대해서만 열어주는 용도 정도로 사용하자.

#cluster, nodegroup sg
resource "aws_security_group" "eks-cluster-sg" {
    name = "eks-cluster-sg"
    description = "security_group for eks-cluster"
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "eks-cluster-sg"
    }

    #내부 통신
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [
            aws_vpc.kube_vpc.cidr_block,
            aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block,
            "${chomp(data.http.myip.body)}/32",
            "0.0.0.0/0"
        ]
        #["0.0.0.0/0"]#
    }

    #NodePort를 위해
    ingress {
        from_port = 30000
        to_port = 32767
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #grafana
    ingress {
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #prometheus
    ingress {
        from_port = var.prometheus_port
        to_port = var.prometheus_port
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #node exporter
    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }



    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

#EKS PODs sg
resource "aws_security_group" "eks-pods-sg"{
    name = "eks-pods-sg"
    description = "sg for eks-pods"
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "eks-pods-sg"
    }

    #내부 통신
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [
            aws_vpc.kube_vpc.cidr_block,
            aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block,
            "${chomp(data.http.myip.body)}/32",
            "0.0.0.0/0"
        ]
    }


    #NodePort를 위해
    ingress {
        from_port = 30000
        to_port = 32767
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #grafana
    ingress {
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #prometheus
    ingress {
        from_port = var.prometheus_port
        to_port = var.prometheus_port
        protocol = "tcp"
        cidr_blocks = [
            "0.0.0.0/0"
        ]
    }

    #node exporter
    ingress {
        from_port = var.node_exporter_port
        to_port = var.node_exporter_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

output "my_ip" {
    value = "${chomp(data.http.myip.body)}/32"
    description = "my ip"
}



resource "aws_security_group" "bastion_sg" {
    name = "bastion_sg"
    vpc_id = aws_vpc.kube_vpc.id

    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        #["${chomp(data.http.myip.body)}/32"]
    }

    ingress {
        from_port = var.access_port
        to_port = var.access_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.grafana_port
        to_port = var.grafana_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.prometheus_port
        to_port = var.prometheus_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.minio_port
        to_port = var.minio_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "bastion-sg"
    }
}



variable "ssh_port" {
    type = number
    default = 22
}

variable "access_port" {
    type = number
    default = 8080
}

variable "grafana_port" {
    type = number
    default = 3000
}

variable "prometheus_port" {
    type = number
    default = 9090
}

variable "node_exporter_port" {
    type = number
    default = 9100
}

variable "minio_port" {
    type = number
    default = 9000
}

