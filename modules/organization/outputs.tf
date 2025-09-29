output "organization_id" {
  description = "The ID of the AWS Organization."
  value       = aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization."
  value       = aws_organizations_organization.main.arn
}

output "root_id" {
  description = "The ID of the root organizational unit."
  value       = aws_organizations_organization.main.roots[0].id
}

output "organizational_units" {
  description = "Map of created organizational units."
  value = {
    for key, ou in aws_organizations_organizational_unit.this : key => {
      id   = ou.id
      arn  = ou.arn
      name = ou.name
    }
  }
}

output "accounts" {
  description = "Map of created AWS accounts."
  value = {
    for key, account in aws_organizations_account.this : key => {
      id    = account.id
      arn   = account.arn
      email = account.email
      name  = account.name
    }
  }
}
