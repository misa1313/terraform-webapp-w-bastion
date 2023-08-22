provider "aws" {
  region     = var.access[2]
}

variable "access" {
  type = list(string)
}

##########################################################################
# Instances for the primary VPC - Autoscaling by CPU utilization
##########################################################################

resource "aws_launch_configuration" "launch_config" {
  name_prefix          = "apache-public-"
  image_id             = "ami-08333bccc35d71140"
  instance_type        = "t2.micro"
  key_name             = "k-priv"
  security_groups      = [aws_security_group.security-group-nat.id]
  iam_instance_profile = aws_iam_instance_profile.apache-main-profile.name
  user_data            = "${file("setup.sh")}"
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.launch_config.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private-subnet.id]
  target_group_arns    = [aws_lb_target_group.target-group.arn]
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