# main.tf (root)
module "organization" {
  source = "./modules/organization"

  common_tags          = local.common_tags
  accounts             = local.accounts
  organizational_units = local.organizational_units
}

module "identity_center" {
  source = "./modules/identity_center"

  accounts = module.organization.accounts

  users               = local.identity_center_users
  groups              = local.identity_center_groups
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}
