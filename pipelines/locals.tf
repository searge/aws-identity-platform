locals {
  common_tags = {
    Project     = "AWS Identity Platform"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Component   = "Pipeline"
  }
}
