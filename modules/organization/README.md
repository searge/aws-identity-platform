# Organization Module

This module manages AWS Organizations infrastructure, including organizational units and member accounts.

## Features

- Creates and manages AWS Organization
- Dynamic organizational unit creation
- Member account provisioning with proper OU placement

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

| Name                                                                                                                                                        | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_organizations_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account)                         | resource |
| [aws_organizations_organization.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization)               | resource |
| [aws_organizations_organizational_unit.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |

## Inputs

| Name                  | Description                           | Type                                                            | Default | Required |
| --------------------- | ------------------------------------- | --------------------------------------------------------------- | ------- | :------: |
| accounts              | A map of AWS accounts to create.      | ```map(object({ name = string email = string ou = string }))``` | `{}`    |    no    |
| common\_tags          | Common tags to apply to all resources | `map(string)`                                                   | `{}`    |    no    |
| organizational\_units | Map of organizational units to create | ```map(object({ name = string }))```                            | `{}`    |    no    |

## Outputs

| Name                  | Description                             |
| --------------------- | --------------------------------------- |
| accounts              | Map of created AWS accounts.            |
| organization\_arn     | The ARN of the AWS Organization.        |
| organization\_id      | The ID of the AWS Organization.         |
| organizational\_units | Map of created organizational units.    |
| root\_id              | The ID of the root organizational unit. |
<!-- END_TF_DOCS -->
