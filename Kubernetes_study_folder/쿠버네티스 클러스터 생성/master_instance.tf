

/*
#온디맨드
resource "aws_instance" "kube_master" {
    ami= "ami-007855ac798b5175e"
    instance_type = "t2.medium"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet.id

    #user_data = see you next time
    security_groups = [aws_security_group.sg_master.id]

    associate_public_ip_address = true

    user_data = data.template_file.kube_master_user_data.rendered

    tags = {
        Name = "kube_master"
    }
}

*/



/*
*/
#master 고가용성 설계 하고 싶으면
resource "aws_spot_instance_request" "kube_master" {
    
    #default is on demand price when max
    #spot price = 이 가격넘으면 안쓰겠습니다.
    #spot_price = ""

    ami= "ami-007855ac798b5175e"
    #2core 4GB, 1core 2GB
    instance_type = "t3.medium"#"t2.small"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet.id

    security_groups = [aws_security_group.sg_master.id]#,
    #                    aws_security_group.sg_worker.id]

    associate_public_ip_address = true

    user_data = data.template_file.kube_master_user_data.rendered

    #이거 안하면 인스턴스 생성이 안되서 아래 태그 resource가 안달림
    wait_for_fulfillment = true
    #spot instance는 이거 해도 이름이 안생긴다???
    #https://github.com/hashicorp/terraform/issues/3263
    #AWS API 중에 spot instance 이름을 넣는 부분이 없다고 함
    #tags = {
    #    Name = "kube_master"
    #}

}

#https://discuss.hashicorp.com/t/aws-spot-instance-request-tags-wont-apply-to-instance/35750
resource "aws_ec2_tag" "master_tag" {
    resource_id = aws_spot_instance_request.kube_master.spot_instance_id
    key = "Name"
    value = "kube_master"
}

data "template_file" "kube_master_user_data" {
    template = file("kube_master_user_data.sh")
}