# Outputs for the SSO Access module

output "permission_sets" {
  description = "Map of created permission sets"
  value       = aws_ssoadmin_permission_set.this
}

output "account_assignments" {
  description = "Map of account assignments"
  value       = aws_ssoadmin_account_assignment.this
}

output "managed_policy_attachments" {
  description = "Map of managed policy attachments"
  value       = aws_ssoadmin_managed_policy_attachment.this
}

output "inline_policy_attachments" {
  description = "Map of inline policy attachments"
  value       = aws_ssoadmin_permission_set_inline_policy.this
}

output "customer_managed_policy_attachments" {
  description = "Map of customer managed policy attachments"
  value       = aws_ssoadmin_customer_managed_policy_attachment.this
}
