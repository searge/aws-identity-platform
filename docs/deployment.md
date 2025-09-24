# Development Guide

## Module Development Principles

This AWS Identity Platform follows infrastructure-as-code best practices with a **module-first approach** where the root module orchestrates specialized sub-modules.

### Architecture Pattern

```bash
Root Module (orchestration)    → Sub-modules (specialized functionality)
├── modules/organization/      # AWS Organizations management
├── modules/identity_center/   # IAM Identity Center (SSO)
├── modules/account_baseline/  # Account standardization
└── modules/permission_management/ # Access control automation
```

## File Organization Standards

### Root Module Structure

```hcl
# main.tf - Module orchestration and composition
module "organization" {
  source = "./modules/organization"
  # Variable passing and dependencies
}

module "identity_center" {
  source = "./modules/identity_center"
  organization_id = module.organization.organization_id
  # Cross-module data flow
}
```

### Standard File Purposes

**main.tf** - Primary entrypoint

- Module calls and resource orchestration
- Cross-module dependencies
- Resource composition logic

**variables.tf** - Input interface

- All variable declarations with descriptions
- Input validation rules
- Type constraints and defaults

**locals.tf** - Data transformation layer

```hcl
locals {
  # Data transformations
  account_map = { for account in var.accounts : account.name => account }

  # Common calculations
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  # Complex mappings for iterations
  ou_policy_attachments = flatten([
    for ou_id, policies in var.ou_policy_map : [
      for policy in policies : {
        ou_id  = ou_id
        policy = policy
      }
    ]
  ])
}
```

**data.tf** - External data queries

```hcl
# AWS Organizations structure
data "aws_organizations_organization" "this" {}

# Identity Center instances
data "aws_ssoadmin_instances" "this" {}

# Current account information
data "aws_caller_identity" "current" {}

# External policy documents
data "aws_iam_policy_document" "trust_policy" {
  # Policy statements
}
```

**outputs.tf** - Module interface

```hcl
output "organization_id" {
  description = "AWS Organization ID"
  value       = aws_organizations_organization.this.id
}
```

## Provider Configuration (2025)

### Required Providers

```hcl
# versions.tf
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.94"  # Stable version, avoid v6.0 beta
    }
  }
}
```

### Provider Authentication

- Use AWS CLI profiles for local development
- Use IAM roles for CI/CD pipelines
- Never hardcode credentials in Terraform files

## Variable Validation Patterns

### Input Validation

```hcl
variable "environment" {
  description = "Environment name (dev or prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "accounts" {
  description = "Map of accounts to create"
  type = map(object({
    name  = string
    email = string
    ou    = string
  }))
  validation {
    condition = alltrue([
      for account in values(var.accounts) :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", account.email))
    ])
    error_message = "All account emails must be valid email addresses."
  }
}
```

### Required Tags Validation

```hcl
variable "tags" {
  description = "Resource tags"
  type        = map(string)
  validation {
    condition = alltrue([
      contains(keys(var.tags), "Environment"),
      contains(keys(var.tags), "Owner"),
      contains(keys(var.tags), "DataClassification")
    ])
    error_message = "Tags must include Environment, Owner, and DataClassification."
  }
}
```

## AWS Identity Center Specifics

### Manual Prerequisites

⚠️ **These steps cannot be automated in Terraform:**

1. Enable IAM Identity Center in AWS Console
2. Configure identity source (Internal directory or External IdP)
3. Set up SCIM integration (if using external IdP)

### Terraform-Managed Resources

```hcl
# Permission sets
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdminAccess"
  description      = "Full administrative access"
  instance_arn     = local.identity_center_arn
  session_duration = "PT8H"
}

# Policy attachments
resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.identity_center_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# Account assignments
resource "aws_ssoadmin_account_assignment" "admin" {
  instance_arn       = local.identity_center_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_id       = data.aws_identitystore_group.admins.group_id
  principal_type     = "GROUP"
  target_id          = var.account_id
  target_type        = "AWS_ACCOUNT"
}
```

## Development Workflow

### Environment Management

```bash
# Development
terraform init -backend-config=env/dev/backend.tfvars
terraform plan -var-file=env/dev/terraform.tfvars -out=dev.tfplan
terraform apply "dev.tfplan"

# Production
terraform init -backend-config=env/prod/backend.tfvars
terraform plan -var-file=env/prod/terraform.tfvars -out=prod.tfplan
terraform apply "prod.tfplan"
```

### Code Quality Standards

#### Pre-commit Checks

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Run module tests
terraform test

# Security scanning
checkov -d .
tfsec .
```

#### Linting Configuration

```hcl
# .tflint.hcl
plugin "aws" {
  enabled = true
  version = "0.40.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}
```

## Security Best Practices

### Least Privilege Implementation

```hcl
# Use data sources instead of hardcoding
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Instead of: account_id = "123456789012"
```

### Sensitive Data Handling

- Store sensitive values in AWS Secrets Manager
- Use Terraform sensitive variables for passwords
- Never commit .tfvars files with secrets
- Use environment variables: `TF_VAR_<variable_name>`

### Resource Protection

```hcl
resource "aws_organizations_organization" "this" {
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}
```

## Testing Approach

### Module Testing

```hcl
# tests/basic.tftest.hcl
run "valid_organization" {
  command = plan

  variables {
    organization_name = "test-org"
    feature_set      = "ALL"
  }

  assert {
    condition     = aws_organizations_organization.this.feature_set == "ALL"
    error_message = "Organization must have ALL features enabled"
  }
}
```

### Integration Testing

- Test cross-module dependencies
- Validate policy attachments
- Test account creation workflows
- Verify permission set assignments

## Common Patterns

### Dynamic Resource Creation

```hcl
# Create multiple permission sets
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name         = each.key
  description  = each.value.description
  instance_arn = local.identity_center_arn
}
```

### Conditional Resource Creation

```hcl
# Create dev account only in dev environment
resource "aws_organizations_account" "dev" {
  count = var.environment == "dev" ? 1 : 0

  name  = "development"
  email = var.dev_account_email
}
```

## Error Prevention

### Common Mistakes

❌ **Don't do:**

- Hardcode account IDs or ARNs
- Skip input validation
- Ignore Terraform state locking
- Mix environments in same state

✅ **Do:**

- Use data sources for dynamic values
- Validate all inputs
- Use remote state with locking
- Separate state files per environment

### Resource Dependencies

```hcl
# Explicit dependencies
resource "aws_ssoadmin_account_assignment" "this" {
  depends_on = [aws_ssoadmin_permission_set.this]
  # Resource configuration
}
```

## Documentation Standards

- All variables must have descriptions
- All outputs must have descriptions
- Use `terraform-docs` for automated README generation
- Document architectural decisions in ADR format
- Keep examples in `examples/` directory

---
*Follow these principles to maintain consistent, secure, and scalable infrastructure code.*
