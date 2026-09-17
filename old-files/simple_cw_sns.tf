# Single instances cloud alarm

resource "aws_sns_topic" "sns_topic" {
  name = "terraform-aws-p2-sns"
}

resource "aws_sns_topic_subscription" "sns_sub" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "rishavsanjan4@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "name" {
  alarm_name          = "terraform-aws-p2-cwma"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 10
  statistic           = "Maximum"
  threshold           = 20
  alarm_description   = "This metric monitors ec2 cpu utilization"

   dimensions = {
    InstanceId = "i-014f69dc606c6941d"
  }

  alarm_actions = [
    aws_sns_topic.sns_topic.arn
  ]
}





