

#vpc 생성
resource "aws_vpc" "kube_vpc" {
    cidr_block = "10.1.0.0/16"

    tags = {
        Name = "kube_vpc"
    }
}

#public subnet 생성
resource "aws_subnet" "public_subnet_a" {
    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "10.1.0.0/24"

    availability_zone = "us-east-1a"

    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_a"
    }
}

resource "aws_subnet" "public_subnet_c" {
    vpc_id = aws_vpc.kube_vpc.id
    cidr_block = "10.1.1.0/24"

    availability_zone = "us-east-1c"

    map_public_ip_on_launch = true

    tags = {
        Name = "public_subnet_c"
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
resource "aws_route_table_association" "public_rt_association_a" {
    subnet_id = aws_subnet.public_subnet_a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_c" {
    subnet_id = aws_subnet.public_subnet_c.id
    route_table_id = aws_route_table.public_rt.id
}

#rt igw 연결
resource "aws_route" "public_rt_igw" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
}


