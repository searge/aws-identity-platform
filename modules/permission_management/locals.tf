# Local values for the Permission Management module

locals {
  # Extract permission set ARNs from the input
  permission_set_arns = {
    for key, ps in var.permission_sets : key => ps.arn
  }
}