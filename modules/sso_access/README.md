# SSO Access Module

## Authorization Layer for AWS IAM Identity Center

This module manages the "what & where" aspect of IAM Identity Center: permission sets, policy attachments, and account assignments.

## Purpose

Following AWS best practices, this module is separated from identity management (users/groups) to:

- Isolate authorization changes from identity changes
- Enable frequent permission updates without affecting identity resources
- Reduce blast radius when modifying permission sets or assignments
- Handle eventual consistency properly with time delays

## Resources Created

- **Permission Sets**: IAM Identity Center permission sets with session duration
- **AWS Managed Policy Attachments**: Links to AWS managed IAM policies
- **Customer Managed Policy Attachments**: Links to customer-created IAM policies in target accounts
- **Inline Policies**: JSON policies embedded directly in permission sets
- **Account Assignments**: Grants users/groups access to accounts with specific permission sets
- **Time Sleep**: Handles AWS IAM Identity Center eventual consistency

## Architecture Decision

This module follows the AWS pattern from:

- [aws-samples/terraform-aws-identity-center](https://github.com/aws-samples/terraform-aws-identity-center)

**Key Benefit**: Combining permission sets with assignments (both authorization concerns) is more logical than separating them, while keeping them separate from identity management prevents refresh storms.

## Usage

```hcl
module "sso_access" {
  source = "./modules/sso_access"

  # Identity dependencies from sso_identities module
  users            = module.sso_identities.users
  groups           = module.sso_identities.groups
  sso_instance_arn = module.sso_identities.sso_instance_arn

  # Organization dependencies from organization module
  accounts = module.organization.accounts

  # Configuration
  permission_sets = {
    Admin = {
      description         = "Full administrative access"
      session_duration    = "PT8H"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    Developer = {
      description        = "Developer access"
      session_duration   = "PT4H"
      inline_policy_file = "policies/developer.json"
      customer_managed_policy_references = [
        {
          name = "CustomS3Policy"
          path = "/"
        }
      ]
    }
  }

  account_assignments = [
    {
      principal_name = "Developers"
      principal_type = "GROUP"
      permission_set = "Developer"
      account_name   = "dev"
    }
  ]
}
```

## Inputs

| Name                | Description                                  | Type         | Default | Required |
| ------------------- | -------------------------------------------- | ------------ | ------- | -------- |
| users               | Map of users from sso_identities module      | map(any)     | {}      | no       |
| groups              | Map of groups from sso_identities module     | map(any)     | {}      | no       |
| sso_instance_arn    | SSO Instance ARN from sso_identities module  | string       | -       | yes      |
| accounts            | Map of AWS accounts from organization module | map(object)  | {}      | no       |
| permission_sets     | Map of permission sets to create             | map(object)  | {}      | no       |
| account_assignments | List of account assignments                  | list(object) | []      | no       |

### Permission Set Object Schema

```hcl
{
  description         = string                # Required: Permission set description
  session_duration    = optional(string)      # Optional: Session duration (default: PT1H)
  managed_policy_arns = optional(list(string))  # Optional: AWS managed policy ARNs
  inline_policy_file  = optional(string)      # Optional: Path to inline policy JSON file
  customer_managed_policy_references = optional(list(object({
    name = string          # Required: Policy name in target accounts
    path = optional(string)  # Optional: IAM policy path (default: /)
  })))
}
```

### Account Assignment Object Schema

```hcl
{
  principal_name = string  # Required: Name of user or group
  principal_type = string  # Required: "USER" or "GROUP"
  permission_set = string  # Required: Permission set name
  account_name   = string  # Required: Account name (key from accounts map)
}
```

## Outputs

| Name                                | Description                                |
| ----------------------------------- | ------------------------------------------ |
| permission_sets                     | Map of created permission sets             |
| account_assignments                 | Map of account assignments                 |
| managed_policy_attachments          | Map of AWS managed policy attachments      |
| customer_managed_policy_attachments | Map of customer managed policy attachments |
| inline_policy_attachments           | Map of inline policy attachments           |

## Policy Types

This module supports **three types of IAM policies** that can be attached to permission sets:

### 1. AWS Managed Policies

Pre-built policies maintained by AWS:

```yaml
AdministratorAccess:
  description: Full administrative access
  managed_policy_arns:
    - arn:aws:iam::aws:policy/AdministratorAccess
```

### 2. Inline Policies

Custom JSON policies embedded in permission sets:

```yaml
DeveloperAccess:
  description: Custom developer access
  inline_policy_file: policies/permission_sets/developer.json
```

### 3. Customer Managed Policies ⚠️

References to IAM policies you create in target accounts:

```yaml
CustomAccess:
  description: Uses customer managed policies
  customer_managed_policy_references:
    - name: MyCustomPolicy      # Must exist in target accounts!
      path: /custom/policies/
```

**IMPORTANT**: Customer managed policies must exist in all target accounts **BEFORE** applying this configuration. Terraform cannot create these policies across accounts - you must deploy them separately.

## Data Transformations

### Managed Policy Attachments Flattening

**Input** (permission sets with policies):

```yaml
Admin:
  managed_policy_arns:
    - arn:aws:iam::aws:policy/AdministratorAccess
    - arn:aws:iam::aws:policy/ReadOnlyAccess
```

**Step 1**: Flatten to list with Cartesian product

```hcl
[
  {
    permission_set: "Admin",
    policy_arn: "arn:aws:iam::aws:policy/AdministratorAccess",
    key: "Admin--arn-aws-iam--aws-policy/AdministratorAccess"
  },
  {
    permission_set: "Admin",
    policy_arn: "arn:aws:iam::aws:policy/ReadOnlyAccess",
    key: "Admin--arn-aws-iam--aws-policy/ReadOnlyAccess"
  }
]
```

**Step 2**: Convert to map for for_each

```hcl
{
  "Admin--arn-aws-iam--aws-policy/AdministratorAccess" = {...},
  "Admin--arn-aws-iam--aws-policy/ReadOnlyAccess" = {...}
}
```

This same pattern is used for customer managed policies and account assignments.

## Eventual Consistency

IAM Identity Center uses eventual consistency. After creating or modifying permission sets, there's a delay before they're available for assignments.

This module handles this with a `time_sleep` resource:

```hcl
resource "time_sleep" "wait_for_permission_sets" {
  depends_on = [
    aws_ssoadmin_permission_set.this,
    aws_ssoadmin_managed_policy_attachment.this,
    aws_ssoadmin_customer_managed_policy_attachment.this,
    aws_ssoadmin_permission_set_inline_policy.this
  ]

  create_duration = "10s"
}
```

Account assignments depend on this sleep to ensure permission sets are ready.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| aws       | ~> 5.94 |
| time      | ~> 0.9  |

## Session Duration Format

Session duration uses ISO 8601 duration format:

- `PT1H` = 1 hour
- `PT4H` = 4 hours
- `PT8H` = 8 hours
- `PT12H` = 12 hours (maximum)

## Integration

This module requires outputs from both `sso_identities` and `organization` modules:

```hcl
module "organization" {
  source = "./modules/organization"
  # ... configuration
}

module "sso_identities" {
  source = "./modules/sso_identities"
  # ... configuration
}

module "sso_access" {
  source = "./modules/sso_access"

  # From sso_identities
  users            = module.sso_identities.users
  groups           = module.sso_identities.groups
  sso_instance_arn = module.sso_identities.sso_instance_arn

  # From organization
  accounts = module.organization.accounts

  # Configuration
  permission_sets     = local.permission_sets
  account_assignments = local.account_assignments
}
```

## Common Patterns

### Multiple Policies per Permission Set

Combine AWS managed and customer managed policies:

```yaml
PowerUser:
  description: Power user access
  session_duration: PT4H
  managed_policy_arns:
    - arn:aws:iam::aws:policy/PowerUserAccess
  customer_managed_policy_references:
    - name: CustomBillingReadAccess
      path: /
```

### Multiple Assignments per Principal

Root-level flattening handles this automatically via `setproduct()`:

```yaml
Developers:
  principal: Developers
  principal_type: GROUP
  permission_sets: ["Developer", "ReadOnly"]  # Both will be assigned
  account_list: ["dev", "staging"]             # To both accounts
```

Result: 4 assignments (2 permission sets × 2 accounts)
