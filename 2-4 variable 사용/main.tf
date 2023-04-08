#54page까지
/*
Deploy a Configurable Web Server

variable로 ip, subnet등을 하드코딩 하지 않고 쓰자

output으로 귀찮게 콘솔 안들어가도 ip 확인 가능
*/
#우분투 22.04 ami
resource "aws_instance" "example" {
    ami = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    #EOF 는 heredoc syntax
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    tags = {
        Name = "terraform-example"
    }
}

#보안그룹
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type = number
    default = 8080
}

output "public_ip" {
    value = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}

