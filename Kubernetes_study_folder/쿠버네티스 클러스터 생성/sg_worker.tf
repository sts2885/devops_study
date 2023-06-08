
resource "aws_security_group" "sg_worker" {
    name = "sg_worker"
    vpc_id = aws_vpc.kube_vpc.id

    #kubelet api : used by self, control plane
    ingress {
        from_port = var.kubelet_api_port
        to_port = var.kubelet_api_port
        protocol = "tcp"
        cidr_blocks = [var.vpc_ip, var.flannel_ip]
    }

    #node port 30000 ~ 32767 : nodeport service
    ingress {
        from_port = var.node_port_from
        to_port = var.node_port_to
        protocol = "tcp"
        cidr_blocks = [var.vpc_ip, var.flannel_ip, var.all_ip]
    }
    #ssh
    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        cidr_blocks = [var.all_ip]
        #cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }

    ingress {
        from_port = var.flannel_udp_port
        to_port = var.flannel_udp_port
        protocol = "udp"
        cidr_blocks = [var.vpc_ip, var.flannel_ip]
    }

    ingress {
        from_port = var.vxlan_udp_port
        to_port = var.vxlan_udp_port
        protocol = "udp"
        cidr_blocks = [var.vpc_ip, var.flannel_ip]
    }

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32", var.vpc_ip, var.flannel_ip]
    }

    ingress {
        from_port = var.http_port
        to_port = var.http_port
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32", var.vpc_ip, var.flannel_ip]
    }

    ingress {
        from_port = var.https_port
        to_port = var.https_port
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.body)}/32", var.vpc_ip, var.flannel_ip]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.all_ip]
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
