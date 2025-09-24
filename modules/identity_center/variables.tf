# Variables for the Identity Center module


variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    description      = string
    session_duration = string
    managed_policies = list(string)
    inline_policy    = optional(string)
  }))
  default = {
    AdminAccess = {
      description      = "Full administrative access"
      session_duration = "PT8H"
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      inline_policy    = null
    }
    DeveloperAccess = {
      description      = "Developer access with limited permissions"
      session_duration = "PT4H"
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      inline_policy    = null
    }
    ReadOnlyAccess = {
      description      = "Read-only access to AWS resources"
      session_duration = "PT2H"
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      inline_policy    = null
    }
  }
}

variable "groups" {
  description = "Map of Identity Store groups to create"
  type = map(object({
    display_name = string
    description  = string
  }))
  default = {
    Administrators = {
      display_name = "Administrators"
      description  = "System administrators with full access"
    }
    Developers = {
      display_name = "Developers"
      description  = "Application developers with limited access"
    }
    ReadOnlyUsers = {
      display_name = "Read-Only Users"
      description  = "Users with read-only access to resources"
    }
  }
}

variable "users" {
  description = "Map of Identity Store users to create"
  type = map(object({
    user_name    = string
    display_name = string
    name = object({
      given_name  = string
      family_name = string
    })
    emails = list(object({
      value   = string
      type    = string
      primary = bool
    }))
  }))
  default = {}
}