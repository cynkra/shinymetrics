resource "aws_autoscaling_group" "drill" {
  name_prefix               = "drill-"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  launch_configuration      = aws_launch_configuration.drill.name
  vpc_zone_identifier       = module.vpc.private_subnets

  tag {
    key                 = "Environment"
    value               = var.PROJ
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "drill-${var.PROJ}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "drill" {
  name_prefix          = "drill-"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.DRILL_INSTANCE_TYPE
  security_groups      = [module.drill.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data            = templatefile("templates/init_drill_ubuntu.tpl", { ssh_keys = [chomp("${file("ssh_keys/john_key.pub")}")] })
}

resource "aws_autoscaling_policy" "drill_up" {
  name                   = "drill_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.drill.name
}

resource "aws_autoscaling_policy" "drill_down" {
  name                   = "drill_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.drill.name
}

resource "aws_cloudwatch_metric_alarm" "drill_up" {
  alarm_name          = "drill_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.drill.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.drill_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "drill_down" {
  alarm_name          = "drill_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.drill.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.drill_down.arn]
}
