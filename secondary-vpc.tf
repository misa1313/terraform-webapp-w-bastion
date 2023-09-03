variable "secondary_vpc_block" {}
variable "secondary_subnet_block" {}
variable "avail_zone3" {}

##########################################################################
# SECONDARY VPC - Subnets - SG - IGW - RT
##########################################################################

resource "aws_vpc" "secondary-vpc" {
  cidr_block       = var.secondary_vpc_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "secondary-vpc"
  }
}

resource "aws_subnet" "secondary-subnet" {
  vpc_id            = aws_vpc.secondary-vpc.id
  cidr_block        = var.secondary_subnet_block
  availability_zone = var.avail_zone3
  map_public_ip_on_launch = true

  tags = {
    Name = "secondary-subnet"
  }
}


resource "aws_security_group" "secondary-sg" {
  name        = "allow_http_ssh2"
  description = "Allow HTTP/SSH inbound traffic"
  vpc_id      = aws_vpc.secondary-vpc.id

  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh2"
  }
}

resource "aws_internet_gateway" "secondary-gateway" {
  vpc_id = aws_vpc.secondary-vpc.id
}

resource "aws_route_table" "secondary-route-table" {
  vpc_id = aws_vpc.secondary-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary-gateway.id
  }
  tags = {
    Name = "secondary-route-table"
  }
}

resource "aws_route_table_association" "secondary-association" {
  subnet_id      = aws_subnet.secondary-subnet.id
  route_table_id = aws_route_table.secondary-route-table.id
}