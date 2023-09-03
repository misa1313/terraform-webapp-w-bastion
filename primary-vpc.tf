variable "primary_vpc_block" {}
variable "private_subnet_block" {}
variable "public_subnet_block" {}
variable "public_subnet_nlb_block" {}
variable "public_subnet_nlb2_block" {}
variable "avail_zone1" {}
variable "avail_zone2" {}

##########################################################################
# MAIN VPC - Subnets - SG - IGW - RT
##########################################################################

resource "aws_vpc" "primary-vpc" {
  cidr_block       = var.primary_vpc_block
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "primary-vpc"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.private_subnet_block
  availability_zone = var.avail_zone1

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.public_subnet_block
  availability_zone = var.avail_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public-subnet-nlb" {
  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.public_subnet_nlb_block
  availability_zone = var.avail_zone1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-nlb"
  }
}

resource "aws_subnet" "public-subnet-nlb2" {
  vpc_id            = aws_vpc.primary-vpc.id
  cidr_block        = var.public_subnet_nlb2_block
  availability_zone = var.avail_zone2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-nlb2"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.primary-vpc.id
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.primary-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "lb-association" {
  subnet_id      = aws_subnet.public-subnet-nlb.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "lb2-association" {
  subnet_id      = aws_subnet.public-subnet-nlb2.id
  route_table_id = aws_route_table.public-route-table.id
}

##########################################################################
# NAT GATEWAY - RT - SG
##########################################################################

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id    = aws_eip.nat_eip_1.id
  subnet_id        = aws_subnet.public-subnet.id

  tags = {
    Name = "NGW for private subnet"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.primary-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_security_group" "security-group-nat" {
  name        = "allow_ssh_httpdlb"
  description = "Allow SSH inbound traffic and HTTP from LB"
  vpc_id      = aws_vpc.primary-vpc.id

  ingress {
    from_port   = -1  
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_block,var.primary_vpc_block,var.public_subnet_nlb_block,var.public_subnet_nlb2_block]  
  }

  ingress {
    description      = "SSH from bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.secondary_vpc_block]
  }

  ingress {
    description      = "HTTP from LB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.public_subnet_nlb_block,var.public_subnet_nlb2_block]
  }

  ingress {
    description      = "HTTPS from LB"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [var.public_subnet_nlb_block,var.public_subnet_nlb2_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_httpdlb"
  }
}