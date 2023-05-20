
#master 고가용성 설계 하고 싶으면
resource "aws_spot_instance_request" "kube_worker" {

    ami= "ami-007855ac798b5175e"
    #2core 4GB, 1core 2GB
    instance_type = "t2.medium"#"t2.small"
    key_name = "DevOps_Study"

    subnet_id = aws_subnet.public_subnet.id

    security_groups = [aws_security_group.sg_worker.id]

    associate_public_ip_address = true

    user_data = data.template_file.kube_worker_user_data.rendered

    wait_for_fulfillment = true

}

#https://discuss.hashicorp.com/t/aws-spot-instance-request-tags-wont-apply-to-instance/35750
resource "aws_ec2_tag" "worker_tag" {
    resource_id = aws_spot_instance_request.kube_worker.spot_instance_id
    key = "Name"
    value = "kube_worker"
}


data "template_file" "kube_worker_user_data" {
    template = file("kube_worker_user_data.sh")
}