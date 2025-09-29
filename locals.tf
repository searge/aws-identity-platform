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
    workloads = {
      name = "Workloads"
    }
  }

  # AWS accounts configuration
  accounts = {
    sandbox_dev = {
      name  = "Sandbox-Dev"
      email = var.sandbox_dev_email
      ou    = "workloads"
    }
    prod = {
      name  = "Prod"
      email = var.prod_email
      ou    = "workloads"
    }
    audit = {
      name  = "Audit"
      email = var.audit_email
      ou    = "workloads"
    }
  }

  # Parse YAML configuration files
  users_yaml               = yamldecode(file("${path.root}/config/users.yaml"))
  groups_yaml              = yamldecode(file("${path.root}/config/groups.yaml"))
  permission_sets_yaml     = yamldecode(file("${path.root}/config/permission_sets.yaml"))
  account_assignments_yaml = yamldecode(file("${path.root}/config/account_assignments.yaml"))

  # Transform YAML data to Terraform format
  identity_center_users = local.users_yaml

  identity_center_groups = {
    for group_key, group_value in local.groups_yaml : group_key => {
      description = group_value.description
      members     = group_value.members
    }
  }

  permission_sets = {
    for ps_key, ps_value in local.permission_sets_yaml : ps_key => {
      description         = ps_value.description
      session_duration    = lookup(ps_value, "session_duration", "PT1H")
      managed_policy_arns = lookup(ps_value, "managed_policy_arns", [])
      inline_policy_file  = lookup(ps_value, "inline_policy_file", null)
    }
  }

  account_assignments = [
    for assignment in local.account_assignments_yaml : {
      principal_name = assignment.principal_name
      principal_type = assignment.principal_type
      account_name   = assignment.account_name
      permission_set = assignment.permission_set
    }
  ]
}
