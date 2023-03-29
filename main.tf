#우분투 22.04 ami
resource "aws_instance" "example" {
    ami = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    #이거 아마 옛날 코드라 안돌아가는 거 같은데
    #문제는 key가 안주어져서 들어가 확인이 불가함.
    #내일 다시 하자
    #EOF 는 heredoc syntax
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
    tags = {
        Name = "terraform-example"
    }
}

#보안그룹
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

