# Outputs from the Account Baseline module

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = aws_cloudtrail.this.arn
}

output "cloudtrail_bucket_name" {
  description = "Name of the S3 bucket for CloudTrail logs"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}

output "config_recorder_name" {
  description = "Name of the Config configuration recorder"
  value       = var.enable_config ? aws_config_configuration_recorder.this[0].name : null
}

output "config_bucket_name" {
  description = "Name of the S3 bucket for Config"
  value       = var.enable_config ? aws_s3_bucket.config[0].bucket : null
}