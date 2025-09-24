# Outputs from the Organization module

output "organization_id" {
  description = "The AWS Organization ID"
  value       = data.aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "The AWS Organization ARN"
  value       = data.aws_organizations_organization.this.arn
}

output "root_ou_id" {
  description = "The root organizational unit ID"
  value       = local.root_ou_id
}

output "organizational_units" {
  description = "Map of organizational units and their details"
  value = {
    for key, ou in aws_organizations_organizational_unit.this : key => {
      id   = ou.id
      arn  = ou.arn
      name = ou.name
    }
  }
}

output "accounts" {
  description = "Map of created accounts and their details"
  value = {
    for key, account in aws_organizations_account.this : key => {
      id    = account.id
      arn   = account.arn
      name  = account.name
      email = account.email
    }
  }
}

output "service_control_policies" {
  description = "Map of created service control policies"
  value = {
    for key, policy in aws_organizations_policy.dev_scp : "dev_scp" => {
      id   = policy.id
      arn  = policy.arn
      name = policy.name
    }
  }
}