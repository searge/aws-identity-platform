variable "users" {
  description = "Map of users to create in IAM Identity Center"
  type = map(object({
    given_name  = string
    family_name = string
    email       = string
  }))
  default = {}
}

variable "groups" {
  description = "Map of groups to create in IAM Identity Center with their members"
  type = map(object({
    description = string
    members     = list(string) # List of user keys to add to this group
  }))
  default = {}
}
