# SSO Identities Module

## Identity Layer for AWS IAM Identity Center

This module manages the "who" aspect of IAM Identity Center: users, groups, and group memberships.

## Purpose

Following AWS best practices, this module is separated from access management (permission sets and assignments) to:

- Isolate identity changes from authorization changes
- Reduce blast radius when modifying users/groups
- Enable independent lifecycle management
- Prevent refresh cascades on large-scale account assignments

## Resources Created

- **Users**: IAM Identity Center users with basic profile information
- **Groups**: IAM Identity Center groups with descriptions
- **Group Memberships**: Assignment of users to groups

## Architecture Decision

This module follows the AWS pattern from:

- [aws-samples/terraform-aws-identity-center-users-and-groups](https://github.com/aws-samples/terraform-aws-identity-center-users-and-groups)

**Key Benefit**: At scale, separating identity from access prevents terraform refresh storms. Example: Adding a user to a group won't trigger refresh of hundreds of account assignments.

## Usage

```hcl
module "sso_identities" {
  source = "./modules/sso_identities"

  users = {
    johndoe = {
      given_name  = "John"
      family_name = "Doe"
      email       = "john.doe@example.com"
    }
  }

  groups = {
    Developers = {
      description = "Application developers"
      members     = ["johndoe"]
    }
  }
}
```

## Inputs

| Name   | Description                          | Type        | Default | Required |
| ------ | ------------------------------------ | ----------- | ------- | -------- |
| users  | Map of users to create               | map(object) | {}      | no       |
| groups | Map of groups to create with members | map(object) | {}      | no       |

### User Object Schema

```hcl
{
  given_name  = string  # Required: User's first name
  family_name = string  # Required: User's last name
  email       = string  # Required: User's email address
}
```

### Group Object Schema

```hcl
{
  description = string        # Required: Group description
  members     = list(string)  # Required: List of user keys to add to group
}
```

## Outputs

| Name              | Description                                   |
| ----------------- | --------------------------------------------- |
| users             | Map of created IAM Identity Center users      |
| groups            | Map of created IAM Identity Center groups     |
| group_memberships | Map of group membership assignments           |
| identity_store_id | The Identity Store ID for IAM Identity Center |
| sso_instance_arn  | The ARN of the IAM Identity Center instance   |

## Data Transformations

### Group Memberships Flattening

The module uses a two-step transformation to flatten group memberships:

**Input** (groups with members):

```yaml
Developers:
  description: "Application developers"
  members: ["alice", "bob"]
```

**Step 1**: Flatten to list with Cartesian product

```hcl
[
  {group_key: "Developers", member_key: "alice", key: "Developers--alice"},
  {group_key: "Developers", member_key: "bob", key: "Developers--bob"}
]
```

**Step 2**: Convert to map for for_each

```hcl
{
  "Developers--alice" = {group_key: "Developers", member_key: "alice"},
  "Developers--bob"   = {group_key: "Developers", member_key: "bob"}
}
```

This pattern enables efficient resource creation with unique keys for terraform state.

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| aws       | ~> 5.94 |

## Notes

- Users are created with minimal profile information (name and email only)
- Display name is automatically constructed from given_name + family_name
- Emails must be unique across the IAM Identity Center instance
- Group names must be unique
- Member keys in groups must reference users defined in the `users` variable

## Integration

This module is designed to work with the `sso_access` module:

```hcl
module "sso_identities" {
  source = "./modules/sso_identities"
  users  = local.users
  groups = local.groups
}

module "sso_access" {
  source = "./modules/sso_access"

  # Pass identity references to access module
  users             = module.sso_identities.users
  groups            = module.sso_identities.groups
  identity_store_id = module.sso_identities.identity_store_id
  sso_instance_arn  = module.sso_identities.sso_instance_arn

  # ... other configuration
}
```
