

#vpc 생성
resource "aws_vpc" "kube_vpc" {
    cidr_block = "10.1.0.0/16"

    tags = {
        Name = "kube_vpc"
    }
}

#public subnet 생성
resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "10.1.0.0/24"

    availability_zone = "us-east-1a"

    tags = {
        Name = "public_subnet"
    }
}

#igw
resource "aws_internet_gateway" "kube_igw" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "kube_igw"
    }
}

#route table
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.kube_vpc.id

    tags = {
        Name = "public_rt"
    }
}

#subnet to rt 연결
resource "aws_route_table_association" "public_rt_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

#rt igw 연결
resource "aws_route" "public_rt_igw" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
}


