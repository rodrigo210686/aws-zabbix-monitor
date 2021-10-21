resource "aws_s3_bucket" "s3_bucket_alerts" {
  bucket = var.lambdaAlerts.s3BucketName
  acl    = "private"
 
  tags = var.alarm_tags
}