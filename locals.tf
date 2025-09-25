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
}
