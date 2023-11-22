
## Send setting files
## Apply secondary cidr

resource "null_resource" "bootstrap_secondary_cidr" {

    depends_on = [
        aws_eks_node_group.eks-nodegroup_1,
        aws_eks_node_group.eks-nodegroup_2,
        aws_instance.bastion
    ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("DevOps_Study.pem")}"
        host = aws_instance.bastion.public_ip
    }

    provisioner "file" {
        source = ".aws"
        destination = "/home/ubuntu"# == "~/.aws"
        #connection {
        #    type = "ssh"
        #    user = "ubuntu"
        #    private_key = "${file("DevOps_Study.pem")}"
        #    host = aws_instance.bastion.public_ip
        #}
    }

    provisioner "file" {
        source = "./k8s-manifests"
        destination = "/home/ubuntu/k8s-manifests"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 777 /home/ubuntu/k8s-manifests/bootstrap_secondary_cidr.sh",
            "bash /home/ubuntu/k8s-manifests/bootstrap_secondary_cidr.sh"
        ]
   }
}


