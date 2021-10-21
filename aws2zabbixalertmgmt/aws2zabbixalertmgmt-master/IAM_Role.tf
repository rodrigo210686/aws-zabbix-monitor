module "iam_assumable_role_custom" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  create_role = true

  role_name         = "CloudWatchToZabbix"
  role_requires_mfa = false

  tags = var.alarm_tags

  custom_role_policy_arns = [
    aws_iam_policy.inetum_mon_policy.arn,
  ]

  depends_on = [
    aws_iam_policy.inetum_mon_policy,
  ]
}