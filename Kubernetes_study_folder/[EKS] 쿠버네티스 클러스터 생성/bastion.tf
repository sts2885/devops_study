
resource "aws_instance" "bastion" {
    ami= "ami-007855ac798b5175e"
    associate_public_ip_address = "true"
    availability_zone = "us-east-1a"

    iam_instance_profile = aws_iam_instance_profile.bastion-ec2-instance-profile.name
    instance_type = "t2.micro"
    key_name = "DevOps_Study"

    #그냥 security group 쓰면 apply 할때마다 지우고 다시 생성함
    subnet_id = aws_subnet.public_subnet_a.id

    #user_data = data.template_file.
    #security_groups = [aws_security_group.bastion_sg.id]
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]

    tags = {
        Name = "bastion server"
    }
}


#eks 완성 후에 해야 돌려야 되고, 파일을 미리 보내둘 수 있어서 의미 없음.
#data "template_file" "bastion_user_data" {
#    template = file("bastion_user_data.sh")
#}



output "bastion_ip" {
    value = aws_instance.bastion.public_ip
}


/*
*/

######bastion에 필요한 파일을 미리 보내기#####
/*
resource "null_resource" "aws-configure" {

    provisioner "file" {
        source = ".aws"
        destination = "/home/ubuntu"# == "~/.aws"

        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("DevOps_Study.pem")}"
            host = aws_instance.bastion.public_ip
        }
    }
}
*/

resource "null_resource" "send_files_and_run_2" {

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
            "chmod 777 /home/ubuntu/k8s-manifests/boot_strapping.sh",
            "bash /home/ubuntu/k8s-manifests/boot_strapping.sh"
        ]
   }
}










