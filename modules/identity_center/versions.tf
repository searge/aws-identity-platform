terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}