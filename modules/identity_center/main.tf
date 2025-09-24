# Identity Center module - manages IAM Identity Center

# Create permission sets
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  session_duration = each.value.session_duration

  tags = merge(var.common_tags, {
    Name = each.key
    Type = "PermissionSet"
  })
}

# Attach managed policies to permission sets
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_value in var.permission_sets : [
        for policy in ps_value.managed_policies : {
          permission_set_key = ps_key
          policy_arn         = policy
          key                = "${ps_key}-${replace(policy, ":", "-")}"
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = local.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
}

# Add inline policies to permission sets (if specified)
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = {
    for key, ps in var.permission_sets : key => ps
    if ps.inline_policy != null
  }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

# Create Identity Store groups
resource "aws_identitystore_group" "this" {
  for_each = var.groups

  display_name      = each.value.display_name
  description       = each.value.description
  identity_store_id = local.identity_store_id
}

# Create Identity Store users
resource "aws_identitystore_user" "this" {
  for_each = var.users

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  user_name         = each.value.user_name

  name {
    given_name  = each.value.name.given_name
    family_name = each.value.name.family_name
  }

  dynamic "emails" {
    for_each = each.value.emails
    content {
      value   = emails.value.value
      type    = emails.value.type
      primary = emails.value.primary
    }
  }
}

