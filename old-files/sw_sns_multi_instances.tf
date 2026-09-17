# Multiple instances cloud alarm

data "aws_instances" "ec2-instances" {

  filter {
    name = "instance-state-name"
    values = ["running"]
  }
  
}

resource "aws_sns_topic" "sns" {
  name = "terraform-aws-p2-multi-instance-alarm"
}

resource "aws_sns_topic_subscription" "asts" {
  topic_arn = aws_sns_topic.sns.arn 
  protocol = "email"
  endpoint = "rishavsanjan4@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "acma" {
  for_each = toset(data.aws_instances.ec2-instances.ids)
  alarm_name = "high-cpu-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = 10
  statistic = "Maximum"
  threshold = 40

  dimensions = {
    InstanceId = each.value
  }

  alarm_actions = [
    aws_sns_topic.sns.arn
  ]
}