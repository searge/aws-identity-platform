terraform {
  # Required Terraform version
  required_version = ">= 1.10"
  required_providers {
    # AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
    # Time Provider (required by sso_access module for eventual consistency handling)
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}
