variable "accounts" {
  description = "Map of AWS accounts from the organization module."
  type = map(object({
    id    = string
    arn   = string
    email = string
    name  = string
  }))
  default = {}
}

variable "users" {
  description = "A map of users to create in IAM Identity Center."
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
  }))
  default = {}
}

variable "groups" {
  description = "A map of groups to create in IAM Identity Center."
  type = map(object({
    description = string
    members     = list(string)
  }))
  default = {}
}

variable "permission_sets" {
  description = "A map of permission sets to create in IAM Identity Center."
  type = map(object({
    description         = string
    session_duration    = optional(string, "PT1H")
    managed_policy_arns = optional(list(string), [])
    inline_policy_file  = optional(string, null)
  }))
  default = {}
}

variable "account_assignments" {
  description = "A list of assignments to link groups/users to permission sets on accounts."
  type = list(object({
    principal_name = string
    principal_type = string
    account_name   = string
    permission_set = string
  }))
  default = []
}
