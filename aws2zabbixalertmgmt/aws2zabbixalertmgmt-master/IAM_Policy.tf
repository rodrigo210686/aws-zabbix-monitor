data "aws_iam_policy_document" "S3_Allow" {
  statement {
    #sid = "SidToOverride"
    effect = "Allow"
    actions   = ["s3:PutObject*"]
    resources = ["arn:aws:s3:::${var.lambdaAlerts.s3BucketName}/*"]
  }
}

resource "aws_iam_policy" "inetum_mon_policy" {
  name   = "inetum-monitoring"
  path   = "/"
  policy = data.aws_iam_policy_document.S3_Allow.json

  tags = var.alarm_tags

  depends_on = [
    data.aws_iam_policy_document.S3_Allow,
  ]
}
