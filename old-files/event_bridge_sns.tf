# This will detect whenever a EC2 instances stops, it will send alert to the subscriber

resource "aws_sns_topic" "sns-topic" {
  name = "ec2-state-change-topic"
}

resource "aws_sns_topic_subscription" "sns-topic-subscription" {
  topic_arn = aws_sns_topic.sns-topic.arn
  protocol  = "email"
  endpoint  = "rishavsanjan0@gmail.com"
}

resource "aws_cloudwatch_event_rule" "cloud-watch-event-rule" {
  name        = "cloud-watch-event-rule"
  description = "Captures event stop in EC2 instances"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["stopped"]
    }
  })
}

resource "aws_cloudwatch_event_target" "event-target" {
  rule      = aws_cloudwatch_event_rule.cloud-watch-event-rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.sns-topic.arn
}

resource "aws_sns_topic_policy" "sns-topic-policy" {
  arn = aws_sns_topic.sns-topic.arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "events.amazonaws.com"
        }

        Action = "sns:Publish"

        Resource = aws_sns_topic.sns-topic.arn
      }
    ]
  })
}