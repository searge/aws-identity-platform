# Variables for the Permission Management module

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "identity_store_id" {
  description = "The Identity Store ID from IAM Identity Center"
  type        = string
}

variable "sso_instance_arn" {
  description = "The ARN of the SSO instance"
  type        = string
}

variable "permission_sets" {
  description = "Map of permission sets from identity_center module"
  type        = any
  default     = {}
}

variable "account_assignments" {
  description = "Map of account assignments"
  type = map(object({
    account_id          = string
    permission_set_name = string
    principal_id        = string
    principal_type      = string
  }))
  default = {}
}

variable "access_review_schedule" {
  description = "Schedule for access reviews (cron expression)"
  type        = string
  default     = "cron(0 9 1 * ? *)" # First day of every month at 9 AM UTC
}

