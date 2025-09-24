# Variables for the Organization module


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

variable "organizational_units" {
  description = "Map of organizational units to create"
  type = map(object({
    name      = string
    parent_id = string
  }))
  default = {
    development = {
      name      = "Development"
      parent_id = "root"
    }
    production = {
      name      = "Production"
      parent_id = "root"
    }
  }
}

variable "accounts" {
  description = "Map of AWS accounts to create"
  type = map(object({
    name    = string
    email   = string
    ou_name = string
  }))
  default = {}
}