# Account Baseline module - applies security baseline to accounts

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket = local.cloudtrail_bucket_name

  tags = merge(var.common_tags, {
    Name = local.cloudtrail_bucket_name
    Type = "CloudTrailBucket"
  })
}

# S3 bucket versioning for CloudTrail
resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption for CloudTrail
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket policy for CloudTrail
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/${var.cloudtrail_s3_key_prefix}/${data.aws_caller_identity.current.account_id}/CloudTrail/${data.aws_region.current.name}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "AWS:SourceArn" = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.cloudtrail_name}"
          }
        }
      }
    ]
  })
}

# CloudTrail
resource "aws_cloudtrail" "this" {
  name           = var.cloudtrail_name
  s3_bucket_name = aws_s3_bucket.cloudtrail.bucket
  s3_key_prefix  = var.cloudtrail_s3_key_prefix

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*/*"]
    }
  }

  tags = merge(var.common_tags, {
    Name = var.cloudtrail_name
    Type = "CloudTrail"
  })

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# GuardDuty detector (if enabled)
resource "aws_guardduty_detector" "this" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          enable = true
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "identity-platform-guardduty"
    Type = "GuardDutyDetector"
  })
}

# Config configuration recorder (if enabled)
resource "aws_config_configuration_recorder" "this" {
  count = var.enable_config ? 1 : 0

  name     = "identity-platform-config-recorder"
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

  depends_on = [aws_config_delivery_channel.this]
}

# Config delivery channel (if enabled)
resource "aws_config_delivery_channel" "this" {
  count = var.enable_config ? 1 : 0

  name           = "identity-platform-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config[0].bucket
}

# S3 bucket for Config (if enabled)
resource "aws_s3_bucket" "config" {
  count = var.enable_config ? 1 : 0

  bucket = local.config_bucket_name

  tags = merge(var.common_tags, {
    Name = local.config_bucket_name
    Type = "ConfigBucket"
  })
}

# Config service role (if enabled)
resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0

  name = "identity-platform-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "identity-platform-config-role"
    Type = "IAMRole"
  })
}

# Attach AWS Config service role policy
resource "aws_iam_role_policy_attachment" "config" {
  count = var.enable_config ? 1 : 0

  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/ConfigRole"
}