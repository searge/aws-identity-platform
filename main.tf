# AWS Identity Platform - Root Module
# This module orchestrates all submodules for the identity platform

# Organization module - manages AWS Organizations structure
module "organization" {
  source = "./modules/organization"

  environment = var.environment
  common_tags = local.common_tags
}

# Identity Center module - manages IAM Identity Center
module "identity_center" {
  source = "./modules/identity_center"

  common_tags = local.common_tags

  # Depends on organization being set up
  depends_on = [module.organization]
}

# Account Baseline module - applies security baseline to accounts
module "account_baseline" {
  source = "./modules/account_baseline"

  common_tags = local.common_tags
  account_id  = local.account_id
  aws_region  = var.aws_region

  # Apply baseline after organization and identity center are set up
  depends_on = [module.organization, module.identity_center]
}

# Permission Management module - manages access lifecycle
module "permission_management" {
  source = "./modules/permission_management"

  environment = var.environment
  common_tags = local.common_tags

  # Get outputs from identity center for permission management
  identity_store_id = module.identity_center.identity_store_id
  sso_instance_arn  = module.identity_center.sso_instance_arn
  permission_sets   = module.identity_center.permission_sets

  depends_on = [module.identity_center]
}