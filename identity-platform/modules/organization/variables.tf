variable "organizational_units" {
  description = "Map of organizational units to create"
  type = map(object({
    name = string
  }))
  default = {}
}

variable "accounts" {
  description = "A map of AWS accounts to create."
  type = map(object({
    name  = string
    email = string
    ou    = string
  }))
  default = {}
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

