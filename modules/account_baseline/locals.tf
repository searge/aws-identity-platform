# Local values for the Account Baseline module

locals {
  # S3 bucket name for CloudTrail (must be globally unique)
  cloudtrail_bucket_name = "identity-platform-cloudtrail-${var.account_id}-${var.aws_region}"

  # Config bucket name
  config_bucket_name = "identity-platform-config-${var.account_id}-${var.aws_region}"
}