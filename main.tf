# main.tf (root) - AWS Way modularization

# Step 1: AWS Organizations
module "organization" {
  source = "./modules/organization"

  common_tags          = local.common_tags
  accounts             = local.accounts
  organizational_units = local.organizational_units
}

# Step 2: SSO Identities (Identity Layer)
# Creates users, groups, and group memberships
module "sso_identities" {
  source = "./modules/sso_identities"

  users  = local.identity_center_users
  groups = local.identity_center_groups
}

# Step 3: SSO Access (Authorization Layer)
# Creates permission sets and account assignments
# Depends on outputs from both organization and sso_identities modules
module "sso_access" {
  source = "./modules/sso_access"

  # Identity dependencies from sso_identities module
  users            = module.sso_identities.users
  groups           = module.sso_identities.groups
  sso_instance_arn = module.sso_identities.sso_instance_arn

  # Organization dependencies from organization module
  accounts = module.organization.accounts

  # Configuration from locals
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}
