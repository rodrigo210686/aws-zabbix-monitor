
data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "AWS2Zabbix.zip"

  source_dir = "AWS2Zabbix/"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"

  function_name = var.lambdaAlerts.name
  description   = var.lambdaAlerts.description
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  attach_policy = true
  timeout       = var.lambdaAlerts.timeout
  policy        = aws_iam_policy.inetum_mon_policy.arn
  tags          = var.alarm_tags

  create_package         = false
  local_existing_package = "AWS2Zabbix.zip"
  environment_variables  = "${local.lambda_environment_variables}"
  vpc_subnet_ids         = var.lambdaAlerts.subnetIds
  vpc_security_group_ids = [aws_security_group.lambda_sg.id]
  attach_network_policy  = true
  
  create_current_version_allowed_triggers = false
  cloudwatch_logs_retention_in_days       = var.lambdaAlerts.logRetention

  allowed_triggers = {
    InetumEventTrigger = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.inetum_event.arn
    }
  }

  depends_on = [
    data.archive_file.lambdazip,
    aws_security_group.lambda_sg,
    #module.iam_policy,
    aws_iam_policy.inetum_mon_policy,
    aws_cloudwatch_event_rule.inetum_event,
    aws_s3_bucket.s3_bucket_alerts,
  ]
}