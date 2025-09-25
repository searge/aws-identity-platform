# main.tf (root)
module "organization" {
  source = "./modules/organization"

  environment = var.environment
  common_tags = local.common_tags
  accounts    = local.accounts
}
