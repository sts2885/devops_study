
#62page
/*
launch configuration이 immutable해서
나중에 뭘 좀 바꾸면,
다 지우고 다시 만듦.
-> 그럼 인스턴스들은 LB 없어서 동작 안하겠네?
-> 그래서 생성을 먼저 하고 난 다음 기존것을 없애라는 명령어인
lifecycle 에서 create_before_destroy를 넣으라는 것

=> example이라는 인스턴스 하나를 코드에서 뺏는데 
자원 지워지나 확인 한번 해봐야 겠음
지워짐. create 후에 지워진건가?

중간에 aws autoscaling group에 authentication이 failure가 났다는데
왜 났는지도 모르겠고
그럼 완성 안됬으면 생성된 인스턴스는 지워야 되는 거 아니냐?

검색해보니까 쿠버네티스나 이런애들도 가끔 나오는 에러인듯
헬스체크에 실패했다.

근데 인스턴스는 8080포트만 뚫어주고
헬스체크는 80번 포트로 시도해서 그런거 같은데
저자는 도대체 왜 성공했다는 거지?

80번 포트 뚫어주니까 생성은 성공
=> auto scaling group에는 헬스 체크 성공함


근데 alb는 503 에러가 뜨고(정상 웹사이트가 떠야됌)

각 서버 따로 8080 들어가보면 안들어가짐 왜?
보니까 타겟 그룹에 타겟이 아무것도 없음.
=> 오타가 났나?

오토 스케일 그룹에 타겟 그룹을 추가 안해줬었음
이미 해놓은 건줄 알고
위아래로 정신없이 왔다갔다 하니까...


이번에는 대상그룹에서 health check가 안된다고 함
왜? 만드는 순서가 안맞아서?

뭐... 내가 해봐도 안들어가 지기는 해
그러고 보니까 헬스체크 포트도 8080으로 되어있던데?
내가 80 추가해준건 의미 없는거 아닌가?

시스템 로그를 보는데...
서버가 깔린 흔적이 없다?

오토스케일 그룹에 연결된 적이 없어서 userdata도 안깔린건가?

생각보다는 그렇게 만능은 아니네?
이미지는 콘솔 절대 안들어가도 될거 같았는데
에러 발생시 대처는 콘솔 없이 힘드네?

오류 생겼다가 코드 고쳐도 자동으로 고쳐질거 같은데
그냥 destroy했다가 다시 해야 되고


원인을 진짜 진짜 모르겠는데 일단은 내일 이어서 하자
뭐... 오타가 있었어도

코드 짜는 방식이 지나치게 위험하긴 해.
조금 짜고 실행하고
조금 짜고 실행하고
할 수 있어야 하는데
거미줄 처럼 복잡한 인프라 구조를 만드는 걸 단순히
암기를 해야 되니까.

일단 8080 포트로 접근도 안되는게 가장 문제인듯

접근이 안되고 health 체크가 전혀 안되니까
한참 뒤에 기존 인스턴스 2개 다 꺼지고
새 인스턴스 2개 켜지더라
그러고도 안들어가짐

다음에 할때는, 콘솔에서 바로 ssh를 들어가면 들어가지나
+
terraform으로 키 넣는 법 찾아보자고

*/


resource "aws_launch_configuration" "example" {
    image_id = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.instance.id]
    key_name = "DevOps_Study"

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    lifecycle {
        create_before_destroy = true
    }
}

//default vpc 쓴다는 뜻
#data "aws_vpc" "default" {
#    default = true
#}


#다른 subnet 쓴다고 하면

#terraform plan 해보니까 이 data가
#옛날버전이라 Deprecated resource라고 함.
#aws_subnet_ids 대신 aws_subnets를 쓰라고 함

/*
#aws_subnet_ids Document
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids

#aws_subnets Document
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets


data "aws_subnets"로 변경

for문으로 묶어버리거나 output 해버릴 수가 있네

#단순 반복문인줄 알았는데 이게 iteration을 하는 거 같은데?
data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.example.ids
  id       = each.value
}

output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.example : s.cidr_block]
}



data "aws_subnets" "default" {
    filter {
        name = "vpc_id"
        values = [data.aws_vpc.default.id]
    }
}
*/

#data "aws_subnet_ids" "default" {
#    vpc_id = data.aws_vpc.default.id
#}
data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}


#vpc_zone_identifier = data.aws_subnet_ids.default.ids
resource "aws_autoscaling_group" "example" {
    launch_configuration = aws_launch_configuration.example.name
    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 10

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

