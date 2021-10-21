resource "aws_cloudwatch_event_rule" "inetum_event" {
  name          = "Inetum_Monitoring"
  description   = "Capture Alarm State Change"
  tags = var.alarm_tags

  event_pattern = jsonencode({ "source" : ["aws.cloudwatch"],"detail-type" : ["CloudWatch Alarm State Change"] })
}

resource "aws_cloudwatch_event_target" "inetum_event_lambda_function" {
  rule = aws_cloudwatch_event_rule.inetum_event.name
  arn  = module.lambda_function.lambda_function_arn
}