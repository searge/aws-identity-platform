# Outputs for the Identity Center module

output "portal_url" {
  description = "The URL to access the IAM Identity Center portal"
  value       = "https://d-${replace(local.identity_store_id, "/^d-/", "")}.awsapps.com/start"
}

output "sso_instance_arn" {
  description = "The ARN of the SSO instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "The ID of the identity store"
  value       = local.identity_store_id
}
