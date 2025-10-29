# Local values and data transformations

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "aws-identity-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Organizational units configuration
  organizational_units = {
    development = {
      name = "Development"
    }
  }

  # AWS accounts configuration
  accounts = {
    sandbox_dev = {
      name  = "Sandbox-Dev"
      email = var.sandbox_dev_email
      ou    = "development"
    }
    prod = {
      name  = "Prod"
      email = var.production_email
      ou    = "development"
    }
    audit = {
      name  = "Audit"
      email = var.audit_email
      ou    = "development"
    }
  }

  # Parse YAML configuration files with template substitution
  users_yaml_raw = yamldecode(
    templatefile("${path.root}/config/users.yaml", {
      superadmin_email = var.superadmin_email
    })
  )
  groups_yaml              = yamldecode(file("${path.root}/config/groups.yaml"))
  permission_sets_yaml     = yamldecode(file("${path.root}/config/permission_sets.yaml"))
  account_assignments_yaml = yamldecode(file("${path.root}/config/account_assignments.yaml"))

  # Transform YAML data to Terraform format
  identity_center_users = local.users_yaml_raw

  identity_center_groups = {
    for group_key, group_value in local.groups_yaml : group_key => {
      description = group_value.description
      members     = group_value.members
    }
  }

  # Pass YAML directly - defaults are handled by optional() in module variables
  permission_sets = local.permission_sets_yaml

  account_assignments = [
    for assignment in local.account_assignments_yaml : {
      principal_name = assignment.principal_name
      principal_type = assignment.principal_type
      account_name   = assignment.account_name
      permission_set = assignment.permission_set
    }
  ]
}

