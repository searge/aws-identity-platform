# Organization module - manages AWS Organizations structure

# Create organizational units
resource "aws_organizations_organizational_unit" "this" {
  for_each = var.organizational_units

  name      = each.value.name
  parent_id = local.ou_parent_ids[each.key]

  tags = merge(var.common_tags, {
    Name = each.value.name
    Type = "OrganizationalUnit"
  })
}

# Create AWS accounts (if specified)
resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = aws_organizations_organizational_unit.this[each.value.ou_name].id
  close_on_deletion          = false
  create_govcloud            = false
  iam_user_access_to_billing = "ALLOW"

  tags = merge(var.common_tags, {
    Name        = each.value.name
    Type        = "Account"
    Environment = var.environment
  })

  lifecycle {
    ignore_changes = [role_name]
  }
}

# Basic Service Control Policy for development accounts
resource "aws_organizations_policy" "dev_scp" {
  count = var.environment == "dev" ? 1 : 0

  name        = "DevelopmentAccountPolicy"
  description = "Service Control Policy for development accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyHighCostServices"
        Effect = "Deny"
        Action = [
          "redshift:*",
          "sagemaker:*",
          "databrew:*",
          "glue:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:PrincipalOrgID" = data.aws_organizations_organization.this.id
          }
        }
      },
      {
        Sid      = "AllowEverythingElse"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "DevelopmentAccountPolicy"
    Type = "ServiceControlPolicy"
  })
}

# Attach SCP to development OU
resource "aws_organizations_policy_attachment" "dev_scp" {
  count = var.environment == "dev" && contains(keys(var.organizational_units), "development") ? 1 : 0

  policy_id = aws_organizations_policy.dev_scp[0].id
  target_id = aws_organizations_organizational_unit.this["development"].id
}