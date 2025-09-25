resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "sso.amazonaws.com"
  ]
  feature_set = "ALL"
}

# Create `aws_organizations_organizational_unit` based on environment-specific OU structure
resource "aws_organizations_organizational_unit" "environment" {
  name      = local.ou_names[var.environment]
  parent_id = aws_organizations_organization.main.roots[0].id

  tags = merge(var.common_tags, {
    Name = local.ou_names[var.environment]
    Type = "OrganizationalUnit"
  })
}
