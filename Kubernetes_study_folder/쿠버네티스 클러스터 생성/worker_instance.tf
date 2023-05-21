

#https://github.com/hashicorp/terraform/issues/3263 
#여러개 쓸꺼면 autoscale group 쓰는게 어떻냐는데?

#launch conf에서 spot instance 쓰려면 그냥 spot 가격만 적어주면 된다고 함.
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration.html


resource "aws_launch_configuration" "kube_worker_lc" {
    image_id = "ami-007855ac798b5175e"

    instance_type = "t2.medium"
    security_groups = [aws_security_group.sg_worker.id]
    key_name = "DevOps_Study"

    #on demanc price 가격 그때그때 다른데 한번 가격 넣어나 볼까? 80퍼 가격으로 
    #https://aws.amazon.com/ko/ec2/spot/pricing/
    spot_price = "0.0363" #2023-05-20 23:42 기준 0.0158
    #가격 0.0158 틀리다고 에러 나옴 $0.0169이 t3.small 인데 그럼그렇지 버그인듯

    user_data = data.template_file.kube_worker_user_data.rendered

    associate_public_ip_address = true

    lifecycle {
        create_before_destroy = true
    }

}


data "template_file" "kube_worker_user_data" {
    template = file("kube_worker_user_data.sh")
}

resource "aws_autoscaling_group" "kube_worker_asg" {
    launch_configuration = aws_launch_configuration.kube_worker_lc.name
    vpc_zone_identifier = [aws_subnet.public_subnet.id]
    #lb를 쓸게 아니라서 target group은 필요없음

    min_size = 2
    max_size = 2

    tag {
        key = "Name"
        value = "kube_worker"
        propagate_at_launch = true
    }
}
