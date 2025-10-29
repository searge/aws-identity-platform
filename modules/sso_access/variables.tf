# Dependencies from sso_identities module
variable "users" {
  description = "Map of users from sso_identities module"
  type        = map(any)
  default     = {}
}

variable "groups" {
  description = "Map of groups from sso_identities module"
  type        = map(any)
  default     = {}
}

variable "sso_instance_arn" {
  description = "SSO Instance ARN from sso_identities module"
  type        = string
}

# Dependencies from organization module
variable "accounts" {
  description = "Map of AWS accounts from organization module"
  type = map(object({
    id    = string
    arn   = string
    email = string
    name  = string
  }))
  default = {}
}

# Configuration
variable "permission_sets" {
  description = "Map of permission sets to create in IAM Identity Center"
  type = map(object({
    description         = string
    session_duration    = optional(string, "PT1H")
    managed_policy_arns = optional(list(string), [])
    inline_policy_file  = optional(string, null)
    customer_managed_policy_references = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
  }))
  default = {}
}

variable "account_assignments" {
  description = "List of assignments to link groups/users to permission sets on accounts"
  type = list(object({
    principal_name = string
    principal_type = string
    account_name   = string
    permission_set = string
  }))
  default = []
}
