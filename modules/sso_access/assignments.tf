resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignments_map

  depends_on = [
    time_sleep.wait_for_permission_sets
  ]

  instance_arn       = var.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_type = each.value.principal_type
  principal_id   = each.value.principal_type == "GROUP" ? var.groups[each.value.principal_name].group_id : var.users[each.value.principal_name].user_id

  target_type = "AWS_ACCOUNT"
  target_id   = var.accounts[each.value.account_name].id
}
