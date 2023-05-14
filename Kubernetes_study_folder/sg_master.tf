
resource "aws_security_group" "sg_master" {
    name = "sg_master"
    vpc_id = aws_vpc.kube_vpc.id

    #api : used by all
    ingress {
        from_port = var.kube_api_port
        to_port = var.kube_api_port
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    #etcd : used by kube api, etcd
    ingress {
        from_port = var.etcd_port_from
        to_port = var.etcd_port_to
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    #variable "kube_controller_manager_port" 10252
    #variable "kube_scheduler_port"10251
    #variable "kubelet_api_port" 10250

    #kubelet api : used by self, control plane
    ingress {
        from_port = var.kubelet_api_port
        to_port = var.kubelet_api_port
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    ingress {
        from_port = var.kube_scheduler_port
        to_port = var.kube_scheduler_port
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    ingress {
        from_port = var.kube_controller_manager_port
        to_port = var.kube_controller_manager_port
        protocol = "tcp"
        cidr_blocks = ["10.1.0.0/24"]
    }

    #ssh
    ingress {
        from_port = var.ssh_port
        to_port = var.ssh_port
        protocol = "tcp"
        #https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add
        cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "kube_api_port" {
    description = "kube api server port"
    type = number
    default = 6443
}

variable "etcd_port_from" {
    description = "etcd port from for kube state store"
    type = number
    default = 2379
}

variable "etcd_port_to" {
    description = "etcd port to for kube state store"
    type = number
    default = 2380
}

variable "kubelet_api_port" {
    description = "kubelet api port"
    type = number
    default=  10250
}

variable "kube_scheduler_port" {
    description = "kube scheduler port"
    type = number
    default = 10251
}

variable "kube_controller_manager_port" {
    description = "kube controller manager port"
    type = number
    default = 10252
}

variable "ssh_port" {
    description = "ssh access port"
    type = number
    default = 22
}


# 내 ip를 일일이 안적고 쓸 수 있는 멋진 방법이 있어서 첨부
# https://stackoverflow.com/questions/46763287/i-want-to-identify-the-public-ip-of-the-terraform-execution-environment-and-add


data "http" "myip" {
    url = "http://ipv4.icanhazip.com"
}

output "my_ip" {
    value = "${chomp(data.http.myip.body)}/32"
    description = "my ip"
}