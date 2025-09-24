# Outputs from the Identity Center module

output "sso_instance_arn" {
  description = "The ARN of the SSO instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "The Identity Store ID"
  value       = local.identity_store_id
}

output "permission_sets" {
  description = "Map of created permission sets"
  value = {
    for key, ps in aws_ssoadmin_permission_set.this : key => {
      arn              = ps.arn
      name             = ps.name
      description      = ps.description
      session_duration = ps.session_duration
    }
  }
}

output "groups" {
  description = "Map of created Identity Store groups"
  value = {
    for key, group in aws_identitystore_group.this : key => {
      group_id     = group.group_id
      display_name = group.display_name
      description  = group.description
    }
  }
}

output "users" {
  description = "Map of created Identity Store users"
  value = {
    for key, user in aws_identitystore_user.this : key => {
      user_id      = user.user_id
      user_name    = user.user_name
      display_name = user.display_name
    }
  }
}