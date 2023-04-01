#ip 한개만 쓰고 싶으니까 ELB 달자 88page
/*
확실히 테라폼이 코드 보기가 매우 불편함
=> 위에서 아래로도 아니고,
=> representation layer -> logic 도 아니고
쉴새없이 위 아래 올렸다 내리면서 봐야 되서
겁나 불편하긴 함.
근데 그래봐야 지금처럼 리소스 단위로 나누면
한파일에 몇개 설정 안들어가긴 하니까...

resource들이 지나치게
거미줄 형태로 엮여 있는데?

솔직히 쓰기 너무 불편함
*/


######## 셋이 한 묶음
resource "aws_lb" "example" {
    name = "terraform-asg-example"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.example.arn
    port = 80
    protocol = "HTTP"

    #By default, return a simple 404 page
    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code = 404
        }
    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"

    #Allow inbound HTTP requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Allow all outbound requests
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
########


#asg에 달아줄 타겟 그룹
#정말 희안한게 이 resource 자체는 위에서 만들어 놓은 lb도
#asg도 둘다 지목을 안함. 각각 따로 눌러줘야 하는 건가?
resource "aws_lb_target_group" "asg" {
    name = "terraform-asg-example"
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}


#이제 작성한 것들을 한군데로 묶어줌
resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "The domain name of the load balancer"
}