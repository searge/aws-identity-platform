# Local values for IAM Identity Center identities

locals {
  # Extract SSO instance details from the data source
  sso_instance_arn  = one(data.aws_ssoadmin_instances.this.arns)
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Flatten group memberships (Cartesian product: groups × members)
  # Step 1: Create flat list with unique keys
  # Example: {Admins: {members: ["alice", "bob"]}} becomes:
  #   [{group_key: "Admins", member_key: "alice"}, {group_key: "Admins", member_key: "bob"}]
  group_memberships_list = flatten([
    for group_key, group_value in var.groups : [
      for member_key in group_value.members : {
        group_key  = group_key
        member_key = member_key
        key        = "${group_key}--${member_key}"
      }
    ]
  ])

  # Step 2: Convert to map for efficient resource creation
  # List → Map conversion for terraform for_each (requires unique keys)
  group_memberships = {
    for item in local.group_memberships_list : item.key => item
  }
}
