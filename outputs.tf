# Root module outputs

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.organization.organization_id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = module.organization.organization_arn
}

output "organizational_units" {
  description = "Map of created organizational units"
  value       = module.organization.organizational_units
}

output "accounts" {
  description = "Map of created AWS accounts"
  value = {
    for key, account in module.organization.accounts : key => {
      id    = account.id
      name  = account.name
      email = account.email
    }
  }
}

output "identity_center_portal_url" {
  description = "The URL to access the IAM Identity Center portal"
  value       = "https://${module.sso_identities.identity_store_id}.awsapps.com/start"
}

output "sso_instance_arn" {
  description = "The ARN of the IAM Identity Center instance"
  value       = module.sso_identities.sso_instance_arn
}

output "identity_store_id" {
  description = "The ID of the Identity Store"
  value       = module.sso_identities.identity_store_id
}

output "permission_sets_summary" {
  description = "Summary of created permission sets"
  value = {
    for ps_key, ps in local.permission_sets : ps_key => {
      description      = ps.description
      session_duration = ps.session_duration
    }
  }
}

output "users_summary" {
  description = "Summary of created users"
  value = {
    for user_key, user in local.identity_center_users : user_key => {
      name  = "${user.given_name} ${user.family_name}"
      email = user.email
    }
  }
}

output "groups_summary" {
  description = "Summary of created groups"
  value = {
    for group_key, group in local.identity_center_groups : group_key => {
      description   = group.description
      members_count = length(group.members)
    }
  }
}