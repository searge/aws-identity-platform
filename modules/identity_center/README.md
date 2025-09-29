# Identity Center Module

This module manages AWS IAM Identity Center (SSO) resources including users, groups, permission sets, and account assignments.

## Features

- User and group management
- Permission sets with managed and inline policies
- Account assignments linking principals to permission sets
- Proper provisioning timing with dependencies

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| aws       | ~> 5.94 |
| time      | ~> 0.9  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | ~> 5.94 |
| time | ~> 0.9  |

## Resources

| Name                                                                                                                                                                | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group)                                     | resource    |
| [aws_identitystore_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership)               | resource    |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user)                                       | resource    |
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment)                     | resource    |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment)       | resource    |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set)                             | resource    |
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource    |
| [time_sleep.wait_for_permission_sets](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                           | resource    |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances)                                    | data source |

## Inputs

| Name                 | Description                                                                | Type                                                                                                                                                                                 | Default | Required |
| -------------------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- | :------: |
| account\_assignments | A list of assignments to link groups/users to permission sets on accounts. | ```list(object({ principal_name = string principal_type = string account_name = string permission_set = string }))```                                                                | `[]`    |    no    |
| accounts             | Map of AWS accounts from the organization module.                          | `any`                                                                                                                                                                                | `{}`    |    no    |
| groups               | A map of groups to create in IAM Identity Center.                          | ```map(object({ description = string members = list(string) }))```                                                                                                                   | `{}`    |    no    |
| permission\_sets     | A map of permission sets to create in IAM Identity Center.                 | ```map(object({ description = string session_duration = optional(string, "PT1H") managed_policy_arns = optional(list(string), []) inline_policy_file = optional(string, null) }))``` | `{}`    |    no    |
| users                | A map of users to create in IAM Identity Center.                           | ```map(object({ given_name = string family_name = string email = string }))```                                                                                                       | `{}`    |    no    |
<!-- END_TF_DOCS -->
