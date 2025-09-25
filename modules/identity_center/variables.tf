variable "accounts" {
  description = "Map of AWS accounts from the organization module."
  type        = any
  default     = {}
}

variable "users" {}
variable "groups" {}
variable "permission_sets" {}
variable "account_assignments" {}
