# Input variables for the AWS Identity Platform
variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile for resource deployment"
  type        = string
  default     = "aws-identity-master"
}
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "sandbox_dev_email" {
  description = "The email address for the Sandbox Dev account's root user."
  type        = string
}

variable "production_email" {
  description = "The email address for the Production account's root user."
  type        = string
}

variable "audit_email" {
  description = "The email address for the Audit account's root user."
  type        = string
}

variable "superadmin_email" {
  description = "The email address for the superadmin user."
  type        = string
}

