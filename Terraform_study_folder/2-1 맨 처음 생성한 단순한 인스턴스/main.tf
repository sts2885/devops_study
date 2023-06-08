#우분투 22.04 ami
resource "aws_instance" "example" {
    ami = "ami-007855ac798b5175e"
    //아래 이미지는 책에 있던건데 이제 이버전(우분투18.04)는 지원 안하나봄
    //"ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
}