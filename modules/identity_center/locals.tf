# Find the SSO instance that was enabled manually
locals {
  sso_instance_arn  = one(data.aws_ssoadmin_instances.this.arns)
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Create a map of assignments for easier lookup
  assignments_map = {
    for assignment in var.account_assignments :
    "${assignment.principal_name}-${assignment.permission_set}-${assignment.account_name}" => assignment
  }
}
