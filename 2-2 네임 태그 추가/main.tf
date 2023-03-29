#우분투 22.04 ami
resource "aws_instance" "example" {
    ami = "ami-007855ac798b5175e"
    instance_type = "t2.micro"

    tags = {
        Name = "terraform-example"
    }
}