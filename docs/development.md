# Development Guide

- [Development Guide](#development-guide)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Configuration Files](#configuration-files)
    - [users.yaml](#usersyaml)
    - [groups.yaml](#groupsyaml)
    - [permission\_sets.yaml](#permission_setsyaml)
    - [account\_assignments.yaml](#account_assignmentsyaml)
  - [Workflow](#workflow)
    - [Initial Setup](#initial-setup)
    - [Making Changes](#making-changes)
  - [Data Transformation](#data-transformation)
  - [Module Interface](#module-interface)
    - [Organization Module](#organization-module)
    - [Identity Center Module](#identity-center-module)
  - [Best Practices](#best-practices)
    - [Configuration Management](#configuration-management)
    - [Security](#security)
    - [Testing](#testing)
    - [State Management](#state-management)
  - [Common Tasks](#common-tasks)
    - [Import Existing Resources](#import-existing-resources)
    - [Debugging](#debugging)
    - [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
    - ["Resource already exists"](#resource-already-exists)
    - ["Cannot delete OU with children"](#cannot-delete-ou-with-children)
    - ["Variable not set"](#variable-not-set)
    - ["Permission set provisioning failed"](#permission-set-provisioning-failed)

## Project Structure

This is a Terraform project managing AWS Organizations and IAM Identity Center with a declarative YAML-based configuration approach.

```bash
.
├── modules/
│   ├── organization/            # AWS Organizations and accounts
│   └── identity_center/         # IAM Identity Center (users, groups, permissions)
├── config/
│   ├── users.yaml               # User definitions
│   ├── groups.yaml              # Group memberships
│   ├── permission_sets.yaml     # Permission set configurations
│   └── account_assignments.yaml # Access mappings
├── policies/
│   └── permission_sets/         # Custom IAM policies for permission sets
├── main.tf                      # Module orchestration
├── locals.tf                    # YAML parsing and data transformation
├── variables.tf                 # Environment variables
└── outputs.tf                   # Exported values
```

## Prerequisites

- Terraform >= 1.10
- AWS CLI configured with master account credentials
- IAM Identity Center enabled in AWS Console (manual step)

## Configuration Files

### users.yaml

Define users with their names and emails:

```yaml
dereban:
  given_name: Max
  family_name: Dereban
  email: ${superadmin_email}  # Uses variable substitution

alice:
  given_name: Alice
  family_name: Admin
  email: alice.admin@example.com
```

### groups.yaml

Define groups and their members:

```yaml
SuperAdmins:
  description: Super administrators with full access to all accounts
  members:
    - dereban

Developers:
  description: Application developers
  members:
    - alice
    - bob
```

### permission_sets.yaml

Define permission sets with session duration and policies:

```yaml
AdministratorAccess:
  description: Full administrative access
  session_duration: PT8H
  managed_policy_arns:
    - arn:aws:iam::aws:policy/AdministratorAccess

DeveloperAccess:
  description: Application development access
  session_duration: PT4H
  inline_policy_file: policies/permission_sets/developer_access.json
```

### account_assignments.yaml

Map groups to accounts with specific permission sets:

```yaml
- principal_name: SuperAdmins
  principal_type: GROUP
  account_name: sandbox_dev
  permission_set: AdministratorAccess

- principal_name: Developers
  principal_type: GROUP
  account_name: sandbox_dev
  permission_set: DeveloperAccess
```

## Workflow

### Initial Setup

1. Set environment variables:

   ```bash
   export TF_VAR_sandbox_dev_email="..."
   export TF_VAR_production_email="..."
   export TF_VAR_audit_email="..."
   export TF_VAR_superadmin_email="..."
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Plan changes:

   ```bash
   terraform plan -out=plan.tfplan
   ```

4. Apply changes:

   ```bash
   terraform apply plan.tfplan
   ```

### Making Changes

1. **Add a new user**:
   - Add to `config/users.yaml`
   - Add to group in `config/groups.yaml`
   - Run `terraform plan` and `apply`

2. **Change user's access**:
   - Modify `config/account_assignments.yaml`
   - Run `terraform plan` and `apply`

3. **Add a new permission set**:
   - Define in `config/permission_sets.yaml`
   - Create custom policy in `policies/permission_sets/` if needed
   - Add assignments in `config/account_assignments.yaml`
   - Run `terraform plan` and `apply`

4. **Add a new account**:
   - Add to `locals.tf` in `accounts` map
   - Add assignments in `config/account_assignments.yaml`
   - Run `terraform plan` and `apply`

## Data Transformation

The `locals.tf` file handles YAML parsing and data transformation:

```hcl
# Parse YAML files
locals {
  users_yaml_raw = yamldecode(
    replace(
      file("${path.root}/config/users.yaml"),
      "${superadmin_email}",
      var.superadmin_email
    )
  )

  # Transform to Terraform structures
  identity_center_users = local.users_yaml_raw

  # ... more transformations
}
```

This allows:

- Variable substitution in YAML files
- Consistent data structure for modules
- Easy configuration updates without touching Terraform code

## Module Interface

### Organization Module

**Inputs**:

- `common_tags`: Tags applied to all resources
- `accounts`: Map of accounts to create
- `organizational_units`: Map of OUs

**Outputs**:

- `organization_id`: AWS Organization ID
- `accounts`: Map of created account IDs
- `organizational_units`: Map of created OU IDs

### Identity Center Module

**Inputs**:

- `accounts`: Account map from organization module
- `users`: User definitions from YAML
- `groups`: Group definitions from YAML
- `permission_sets`: Permission set configurations from YAML
- `account_assignments`: Access mappings from YAML

**Outputs**:

- `sso_instance_arn`: Identity Center instance ARN
- `sso_portal_url`: SSO login portal URL
- User, group, and permission set details

## Best Practices

### Configuration Management

- **Version Control**: Commit all YAML configuration files
- **Variable Substitution**: Use `${variable_name}` in YAML for dynamic values
- **Least Privilege**: Start with minimal permissions, expand as needed
- **Documentation**: Add comments in YAML files explaining access decisions

### Security

- **Never commit secrets**: Use environment variables for sensitive data
- **MFA Required**: Configure MFA in Identity Center console
- **Regular Reviews**: Audit `config/account_assignments.yaml` regularly
- **Separation of Duties**: Use different groups for different roles

### Testing

Before applying to production:

1. Run `terraform fmt -recursive` to format code
2. Run `terraform validate` to check syntax
3. Run `terraform plan` and review changes carefully
4. Test in non-production accounts first

### State Management

- Use remote state (S3 + DynamoDB) for team collaboration
- Configure in `backend.tf`
- Never manually edit state files

## Common Tasks

### Import Existing Resources

If resources exist outside Terraform:

```bash
# Import organization
terraform import module.organization.aws_organizations_organization.main o-xxxxxxxxxx

# Import existing user
terraform import module.identity_center.aws_identitystore_user.this[\"username\"] d-xxxxxxxxxx/user-id
```

### Debugging

Enable detailed logs:

```bash
export TF_LOG=DEBUG
terraform plan
```

View specific resource details:

```bash
terraform state show module.identity_center.aws_identitystore_user.this[\"dereban\"]
```

### Validation

Check configuration syntax:

```bash
terraform validate
```

Format all files:

```bash
terraform fmt -recursive
```

## Troubleshooting

### "Resource already exists"

Resource was created outside Terraform. Use `terraform import` to bring it into state.

### "Cannot delete OU with children"

Remove child accounts from OU first, or avoid replacing OUs by importing the organization.

### "Variable not set"

Ensure all required environment variables are exported:

```bash
export TF_VAR_sandbox_dev_email="..."
```

### "Permission set provisioning failed"

Wait a few minutes and retry. Permission set provisioning can be eventually consistent.
