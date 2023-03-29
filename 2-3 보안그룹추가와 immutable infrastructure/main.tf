#우분투 22.04 ami
resource "aws_instance" "example" {
    ami = "ami-007855ac798b5175e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

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

