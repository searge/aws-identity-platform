resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = local.identity_store_id
  display_name      = "${each.value.given_name} ${each.value.family_name}"
  user_name         = each.key

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    primary = true
    value   = each.value.email
  }
}

resource "aws_identitystore_group" "this" {
  for_each = var.groups

  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value.description
}

# Create a flattened map of all memberships
locals {
  group_memberships = flatten([
    for group_key, group_value in var.groups : [
      for member_key in group_value.members : {
        group_key  = group_key
        member_key = member_key
      }
    ]
  ])
  group_memberships_map = {
    for membership in local.group_memberships :
    "${membership.group_key}-${membership.member_key}" => membership
  }
}

resource "aws_identitystore_group_membership" "this" {
  for_each = local.group_memberships_map

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_key].group_id
  member_id         = aws_identitystore_user.this[each.value.member_key].user_id
}
