output "accounts" {
  description = "A map of the created AWS accounts."
  value       = aws_organizations_account.this
}
