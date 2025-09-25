# Identity Center Module

This module manages AWS IAM Identity Center (formerly AWS SSO) resources, including permission sets, users, and groups. It provides centralized identity management and single sign-on capabilities for the AWS organization.

## Features

- Creates and manages IAM Identity Center permission sets
- Attaches managed and inline policies to permission sets
- Manages Identity Store users and groups
- Configures session duration and access policies

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| aws       | ~> 5.94 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | ~> 5.94 |

## Resources

| Name                                                                                                                                                                | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group)                                     | resource    |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user)                                       | resource    |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment)       | resource    |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set)                             | resource    |
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource    |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                                    | data source |

## Inputs

| Name             | Description                            | Type                                                                                                                                                                                               | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | Required |
| ---------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| common\_tags     | Common tags to apply to all resources  | `map(string)`                                                                                                                                                                                      | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |    no    |
| groups           | Map of Identity Store groups to create | ```map(object({ display_name = string description = string }))```                                                                                                                                  | ```{ "Administrators": { "description": "System administrators with full access", "display_name": "Administrators" }, "Developers": { "description": "Application developers with limited access", "display_name": "Developers" }, "ReadOnlyUsers": { "description": "Users with read-only access to resources", "display_name": "Read-Only Users" } }```                                                                                                                                                                                                                                                  |    no    |
| permission\_sets | Map of permission sets to create       | ```map(object({ description = string session_duration = string managed_policies = list(string) inline_policy = optional(string) }))```                                                             | ```{ "AdminAccess": { "description": "Full administrative access", "inline_policy": null, "managed_policies": [ "arn:aws:iam::aws:policy/AdministratorAccess" ], "session_duration": "PT8H" }, "DeveloperAccess": { "description": "Developer access with limited permissions", "inline_policy": null, "managed_policies": [ "arn:aws:iam::aws:policy/PowerUserAccess" ], "session_duration": "PT4H" }, "ReadOnlyAccess": { "description": "Read-only access to AWS resources", "inline_policy": null, "managed_policies": [ "arn:aws:iam::aws:policy/ReadOnlyAccess" ], "session_duration": "PT2H" } }``` |    no    |
| users            | Map of Identity Store users to create  | ```map(object({ user_name = string display_name = string name = object({ given_name = string family_name = string }) emails = list(object({ value = string type = string primary = bool })) }))``` | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |    no    |

## Outputs

| Name                | Description                          |
| ------------------- | ------------------------------------ |
| groups              | Map of created Identity Store groups |
| identity\_store\_id | The Identity Store ID                |
| permission\_sets    | Map of created permission sets       |
| sso\_instance\_arn  | The ARN of the SSO instance          |
| users               | Map of created Identity Store users  |
<!-- END_TF_DOCS -->
