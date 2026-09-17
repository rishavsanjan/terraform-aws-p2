resource "aws_sns_topic" "sns_topic" {
  name = "terraform-aws-p2-multi-instance-alarm"
}

resource "aws_sns_topic_subscription" "sns_topic_sub" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "rishavsanjan4@gmail.com"
}


resource "aws_iam_role" "lambda_role" {
  name = "ec2-notification-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]

  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.sns_topic.arn
      }
    ]

  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ec2_notification" {
  filename         = "lambda.zip"
  function_name    = "ec2-notification"
  role             = aws_iam_role.lambda_role.arn
  handler          = "ec2_notification.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime          = "python3.12"
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sns_topic.arn
    }
  }

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
  target_id = "SendToLambda"
  arn       = aws_lambda_function.ec2_notification.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id = "AllowExecutionFromEventBridge"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_notification.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.cloud-watch-event-rule.arn
}




