resource "aws_autoscaling_group" "app" {
  name_prefix               = "app-"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.app.name
  vpc_zone_identifier       = module.vpc.private_subnets
  target_group_arns         = module.alb.target_group_arns

  tag {
    key                 = "Environment"
    value               = var.PROJ
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "app-${var.PROJ}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "app" {
  name_prefix     = "app-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.APP_INSTANCE_TYPE
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name
  security_groups = [module.app_sg.security_group_id]
  user_data       = templatefile("templates/init_app_ubuntu.tftpl", { ssh_keys = [chomp("${file("ssh_keys/john_key.pub")}")], db_url = module.mysql.db_instance_address, db_user = module.mysql.db_instance_username, db_pass = module.mysql.db_instance_password })
}

resource "aws_autoscaling_policy" "app_up" {
  name                   = "app_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_autoscaling_policy" "app_down" {
  name                   = "app_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_cloudwatch_metric_alarm" "app_up" {
  alarm_name          = "app_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.app_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "app_down" {
  alarm_name          = "app_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.app_down.arn]
}
