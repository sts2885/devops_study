
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










