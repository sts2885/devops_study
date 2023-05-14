

/*
resource "aws_instance" "kube_spot" {
    ami= "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet.id

    #user_data = see you next time
    security_groups = [aws_security_group.sg_master.id,
                        aws_security_group.sg_worker.id]

    associate_public_ip_address = true

    tags = {
        Name = "kube_spot"
    }
}
*/

resource "aws_spot_instance_request" "kube_spot" {
    
    #default is on demand price when max
    #spot price = 이 가격넘으면 안쓰겠습니다.
    #spot_price = ""

    ami= "ami-007855ac798b5175e"
    #2core 4GB, 1core 2GB
    instance_type = "t2.medium"#"t2.small"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet.id

    #user_data = 

    security_groups = [aws_security_group.sg_master.id,
                        aws_security_group.sg_worker.id]

    associate_public_ip_address = true

    tags = {
        Name = "kube_spot"
    }

}

output "test_instance" {
    value = aws_spot_instance_request.kube_spot.public_ip
    description = "instance ip"
}

data "aws_instances" "test_instances" {
    instance_tags = {
        Name = "kube_spot"
    }
}

output "instance_ip" {
    value = "${data.aws_instances.test_instances.public_ips}"
}