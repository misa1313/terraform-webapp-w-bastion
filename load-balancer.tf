##########################################################################
# Load balancer SG
##########################################################################

resource "aws_security_group" "load-balancer-sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.primary-vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from LB"
    from_port        = 443
    to_port          = 443
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
    Name = "allow_http"
  }
}

##########################################################################
# Load balancer - Target group - AWS route53
##########################################################################

resource "aws_lb" "load-balancer-lb" {
  name               = "load-balancer-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups   = [aws_security_group.load-balancer-sg.id]
  subnets            = [aws_subnet.public-subnet-nlb.id,aws_subnet.public-subnet-nlb2.id]
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "load-balancer-listener" {
  load_balancer_arn = aws_lb.load-balancer-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_target_group" "target-group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.primary-vpc.id
}

resource "aws_route53_zone" "load-balancer-zone" {
  name    = "kinntel.com"
  comment = "Zone for kinntel.com"
}

resource "aws_route53_record" "load-balancer-record" {
  zone_id = aws_route53_zone.load-balancer-zone.zone_id
  name    = "aws.kinntel.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.load-balancer-lb.dns_name]
}




