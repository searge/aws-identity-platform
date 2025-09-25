# Local values and data transformations

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "aws-identity-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  accounts = {
    "sandbox_dev" = {
      name  = "Sandbox-Dev"
      email = var.sandbox_dev_email
      ou    = "Development"
    }
  }

  # Pass-through variables for identity center
  identity_center_users  = var.identity_center_users
  identity_center_groups = var.identity_center_groups
  permission_sets        = var.permission_sets
  account_assignments    = var.account_assignments
}
