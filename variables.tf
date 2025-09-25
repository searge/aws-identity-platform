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

variable "identity_center_users" {
  description = "A map of users to create in IAM Identity Center."
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
  }))
  default = {}
}

variable "identity_center_groups" {
  description = "A map of groups to create in IAM Identity Center."
  type = map(object({
    description = string
    members     = list(string) # List of user keys from identity_center_users
  }))
  default = {}
}

variable "permission_sets" {
  description = "A map of permission sets to create in IAM Identity Center."
  type = map(object({
    description         = string
    session_duration    = optional(string, "PT1H")
    managed_policy_arns = optional(list(string), [])
    # customer_managed_policy_references can be added later
  }))
  default = {}
}

variable "account_assignments" {
  description = "A list of assignments to link groups/users to permission sets on accounts."
  type = list(object({
    principal_name = string # The key of the group/user
    principal_type = string # GROUP or USER
    account_name   = string # The key of the account
    permission_set = string # The key of the permission set
  }))
  default = []
}
