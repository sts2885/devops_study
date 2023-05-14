
resource "aws_security_group" "sg_worker" {
    name = "sg_worker"
    vpc_id = aws_vpc.kube_vpc.id

    #kubelet api : used by self, control plane
    ingress {
        from_port = var.kubelet_api_port
        to_port = var.kubelet_api_port
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    #node port 30000 ~ 32767 : nodeport service
    ingress {
        from_port = var.node_port_from
        to_port = var.node_port_to
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }
    #ssh
    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#10250 kubelet api used by self, control plane
#30000 ~ 32767 nodeport service / used by all

#var "kubelet_api_port" 10250 <- already in sg master

variable "node_port_from" {
    description = "node port for worker start"
    type = number
    default = 30000
}

variable "node_port_to" {
    description = "node port for worker end "
    type = number
    default=  32767
}