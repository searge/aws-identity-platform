# Outputs for the SSO Identities module

output "users" {
  description = "Map of created IAM Identity Center users"
  value       = aws_identitystore_user.this
}

output "groups" {
  description = "Map of created IAM Identity Center groups"
  value       = aws_identitystore_group.this
}

output "group_memberships" {
  description = "Map of group membership assignments"
  value       = aws_identitystore_group_membership.this
}

output "identity_store_id" {
  description = "The Identity Store ID for IAM Identity Center"
  value       = local.identity_store_id
}

output "sso_instance_arn" {
  description = "The ARN of the IAM Identity Center instance"
  value       = local.sso_instance_arn
}
