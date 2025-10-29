resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = var.sso_instance_arn
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.policy_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = {
    for ps_key, ps in var.permission_sets : ps_key => ps
    if ps.inline_policy_file != null
  }

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
  inline_policy      = file(each.value.inline_policy_file)
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = local.customer_managed_policy_attachments

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }
}

# AWS IAM Identity Center has eventual consistency.
# Permission sets may not be immediately available for assignments after creation.
# This wait ensures permission sets are fully propagated before assignments.
# See: https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-considerations.html
resource "time_sleep" "wait_for_permission_sets" {
  depends_on = [
    aws_ssoadmin_permission_set.this,
    aws_ssoadmin_managed_policy_attachment.this,
    aws_ssoadmin_customer_managed_policy_attachment.this,
    aws_ssoadmin_permission_set_inline_policy.this
  ]

  create_duration = "10s"
}
