# Local values and data transformations

locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = "aws-identity-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

}
