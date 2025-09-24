# Local values and data transformations

locals {
  # Account and region information (defined first to avoid cycles)
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # Common tags applied to all resources
  common_tags = {
    Project     = "aws-identity-platform"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}