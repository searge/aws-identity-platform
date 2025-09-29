# Development Guide

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
- IAM Identity Center enabled in AWS Console

## Configuration Files

All configuration is defined in YAML files under `config/`:

- `users.yaml` - User definitions with names and emails
- `groups.yaml` - Group definitions and memberships
- `permission_sets.yaml` - Permission sets with policies and session durations
- `account_assignments.yaml` - Mappings of groups to accounts and permission sets

Variable substitution is supported using `${variable_name}` syntax.

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

`locals.tf` parses YAML files and transforms them for module consumption, supporting variable substitution (e.g., `${superadmin_email}`) for dynamic values.

## Module Interface

See module READMEs for detailed inputs/outputs:
- [modules/organization/README.md](../modules/organization/README.md)
- [modules/identity_center/README.md](../modules/identity_center/README.md)

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

Before applying:

1. Validate YAML: `yq eval config/*.yaml` or `python -m yaml config/*.yaml`
2. Format: `terraform fmt -recursive`
3. Validate: `terraform validate`
4. Review: `terraform plan`

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
