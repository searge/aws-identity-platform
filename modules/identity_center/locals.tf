# Find the SSO instance that was enabled manually
locals {
  sso_instance_arn  = one(data.aws_ssoadmin_instances.this.arns)
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Create a map of assignments for easier lookup
  assignments_map = {
    for assignment in var.account_assignments :
    "${assignment.principal_name}-${assignment.permission_set}-${assignment.account_name}" => assignment
  }

  # Flatten managed policy attachments
  # Step 1: Create flat list
  policy_attachments_list = flatten([
    for ps_key, ps in var.permission_sets : [
      for policy_arn in ps.managed_policy_arns : {
        permission_set = ps_key
        policy_arn     = policy_arn
        key            = "${ps_key}--${replace(policy_arn, ":", "-")}"
      }
    ]
  ])

  # Step 2: Convert to map
  managed_policy_attachments = {
    for item in local.policy_attachments_list : item.key => item
  }

  # Flatten group memberships
  # Step 1: Create flat list
  group_memberships_list = flatten([
    for group_key, group_value in var.groups : [
      for member_key in group_value.members : {
        group_key  = group_key
        member_key = member_key
        key        = "${group_key}--${member_key}"
      }
    ]
  ])

  # Step 2: Convert to map
  group_memberships = {
    for item in local.group_memberships_list : item.key => item
  }
}
