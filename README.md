# AWS Identity Platform

Terraform configuration for managing AWS Organizations and IAM Identity Center across multiple accounts.

## Documentation

- [Architecture](docs/architecture.md)
- [Development](docs/development.md)
- [Security](docs/security.md)

## Structure

```bash
modules/
├── organization/     # AWS Organizations and accounts
└── identity_center/  # IAM Identity Center (SSO)

config/
├── users.yaml                # User definitions
├── groups.yaml               # Group memberships
├── permission_sets.yaml      # Permission set configurations
└── account_assignments.yaml  # Group-to-account mappings
```

## Features

- **AWS Organizations**: Master account with Development OU containing Sandbox-Dev, Prod, and Audit accounts
- **IAM Identity Center**: Centralized SSO with declarative user, group, and permission management
- **Configuration-as-Code**: All identities and permissions defined in YAML files

## Groups & Access

- **SuperAdmins**: Full administrative access to all accounts
- **PlatformAdmins**: Full administrative access to all accounts
- **Developers**: Developer access to Sandbox-Dev, read-only to Prod
- **DevOpsEngineers**: Infrastructure admin access to Sandbox-Dev and Prod
- **SecurityAuditors**: Security audit access across all accounts

## Requirements

- Terraform >= 1.10
- AWS CLI configured with organization master account credentials
- Environment variables for account emails (see `terraform.tfvars`)

## Usage

Set required environment variables:

```bash
export TF_VAR_sandbox_dev_email="..."
export TF_VAR_production_email="..."
export TF_VAR_audit_email="..."
export TF_VAR_superadmin_email="..."
```

Apply configuration:

```bash
terraform init
terraform plan -out=plan.tfplan
terraform apply plan.tfplan
```

## Outputs

After applying, access the Identity Center portal at the URL provided in outputs to configure user passwords and MFA.

## References

### Official AWS Samples

- [aws-samples/terraform-aws-identity-center](https://github.com/aws-samples/terraform-aws-identity-center) - Permission sets and account assignments
- [aws-samples/terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups) - Users and groups management
- [aws-ia/terraform-aws-iam-identity-center](https://github.com/aws-ia/terraform-aws-iam-identity-center) - AWS IA official module

### Best Practices

- [Terraform Best Practices by Anton Babenko](https://www.terraform-best-practices.com)
- [AWS IAM Identity Center Documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html)
- [Terraform Registry: AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
