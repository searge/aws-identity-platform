# main.tf (root)
module "organization" {
  source = "./modules/organization"

  environment = var.environment
  common_tags = local.common_tags
  accounts    = local.accounts
}

module "identity_center" {
  source = "./modules/identity_center"

  accounts = module.organization.accounts

  users               = local.identity_center_users
  groups              = local.identity_center_groups
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}
