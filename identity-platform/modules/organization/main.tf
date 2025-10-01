resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "sso.amazonaws.com"
  ]
  feature_set = "ALL"
}

# Create organizational units dynamically
resource "aws_organizations_organizational_unit" "this" {
  for_each = local.ou_names

  name      = each.value
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = merge(var.common_tags, {
    Name = each.value
    Type = "OrganizationalUnit"
  })
}

# Create `aws_organizations_account` for each account
resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name  = each.value.name
  email = each.value.email

  parent_id = aws_organizations_organizational_unit.this[each.value.ou].id

  # Ensure the account can be closed via Terraform
  close_on_deletion = true

  tags = merge(var.common_tags, {
    Name = each.value.name
    Type = "AWSAccount"
  })
}
