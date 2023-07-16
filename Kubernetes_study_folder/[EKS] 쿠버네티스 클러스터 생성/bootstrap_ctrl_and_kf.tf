
## Install AWS Controllers
## Install Kubeflow

resource "null_resource" "bootstrap_ctrl_and_kf" {

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

    provisioner "remote-exec" {
        inline = [
            "chmod 777 /home/ubuntu/k8s-manifests/bootstrap_ctrl_and_kf.sh",
            "bash /home/ubuntu/k8s-manifests/bootstrap_ctrl_and_kf.sh",
            "nohup bash /home/ubuntu/port_forward.sh 0<&- &> /home/ubuntu/kubeflow.log &",
            "sleep 1",
            "nohup bash /home/ubuntu/port_forward_minio.sh 0<&- &> /home/ubuntu/kubeflow2.log &",
            "sleep 1",
            "sudo apt install -y net-tools"
        ]
   }
}


