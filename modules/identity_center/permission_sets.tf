resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.key
  description      = each.value.description
  instance_arn     = local.sso_instance_arn
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for item in flatten([
      for ps_key, ps in var.permission_sets : [
        for policy_arn in ps.managed_policy_arns : {
          key            = "${ps_key}-${policy_arn}"
          permission_set = ps_key
          policy_arn     = policy_arn
        }
      ]
    ]) : item.key => item
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn
  managed_policy_arn = each.value.policy_arn
}
