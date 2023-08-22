provider "aws" {
  region     = var.access[2]
}

variable "access" {
  type = list(string)
}

##########################################################################
# Instances for the primary VPC - Autoscaling by CPU utilization
##########################################################################

resource "aws_launch_template" "launch_template" {
  name_prefix               = "apache-public-"
  image_id                  = "ami-08333bccc35d71140"
  instance_type             = "t2.micro"
  key_name                  = "k-priv"
  vpc_security_group_ids    = [aws_security_group.security-group-nat.id]
  user_data                 = filebase64("./setup.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.apache-main-profile.name
  }
  metadata_options {
    instance_metadata_tags      = "enabled"
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      environment = "dev"
    }
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_template {
    id      = aws_launch_template.launch_template.id
  }
  min_size                  = 2
  max_size                  = 4
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.private-subnet.id]
  target_group_arns         = [aws_lb_target_group.target-group.arn]
}

resource "aws_autoscaling_policy" "scale-policy" {
  name                   = "scale-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name

  target_tracking_configuration {
    target_value           = 80.0
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"   
    }
  }
}


##########################################################################
# Bastion host on secondary VPC
##########################################################################

resource "aws_instance" "bastion-host" {
  ami           = "ami-08333bccc35d71140"
  instance_type = "t2.micro"
  key_name = "k1"
  vpc_security_group_ids = [aws_security_group.secondary-sg.id]
  subnet_id = aws_subnet.secondary-subnet.id
  user_data = "${file("setup-bastion.sh")}"
  tags = {
    Name = "bastion-host"
    environment = "dev"
  }

}