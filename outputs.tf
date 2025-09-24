# Outputs from the AWS Identity Platform

# Organization outputs
output "organization_id" {
  description = "The AWS Organization ID"
  value       = module.organization.organization_id
}

output "organizational_units" {
  description = "Map of organizational units and their IDs"
  value       = module.organization.organizational_units
}

# Identity Center outputs
output "identity_store_id" {
  description = "The Identity Store ID for IAM Identity Center"
  value       = module.identity_center.identity_store_id
}

output "sso_instance_arn" {
  description = "The ARN of the SSO instance"
  value       = module.identity_center.sso_instance_arn
}

output "permission_sets" {
  description = "Map of created permission sets"
  value       = module.identity_center.permission_sets
}

# Account baseline outputs
output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = module.account_baseline.cloudtrail_arn
}

# Common information
output "account_id" {
  description = "Current AWS Account ID"
  value       = local.account_id
}

output "region" {
  description = "Current AWS Region"
  value       = local.region
}