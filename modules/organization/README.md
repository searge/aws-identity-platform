# Organization Module

This module manages the AWS Organizations structure, including organizational units (OUs), AWS accounts, and service control policies (SCPs). It creates the foundational organizational hierarchy for the identity platform.

## Features

- Creates organizational units with hierarchical structure
- Provisions AWS accounts within specific OUs
- Applies service control policies for development environments
- Implements security guardrails through SCPs

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| aws       | ~> 5.94 |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | 5.100.0 |

## Resources

| Name                                                                                                                                                        | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_organizations_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account)                         | resource    |
| [aws_organizations_organizational_unit.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource    |
| [aws_organizations_policy.dev_scp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy)                        | resource    |
| [aws_organizations_policy_attachment.dev_scp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment)  | resource    |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization)            | data source |

## Inputs

| Name                  | Description                           | Type                                                                 | Default                                                                                                                              | Required |
| --------------------- | ------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | :------: |
| accounts              | Map of AWS accounts to create         | ```map(object({ name = string email = string ou_name = string }))``` | `{}`                                                                                                                                 |    no    |
| common\_tags          | Common tags to apply to all resources | `map(string)`                                                        | `{}`                                                                                                                                 |    no    |
| environment           | Environment name (dev/prod)           | `string`                                                             | n/a                                                                                                                                  |   yes    |
| organizational\_units | Map of organizational units to create | ```map(object({ name = string parent_id = string }))```              | ```{ "development": { "name": "Development", "parent_id": "root" }, "production": { "name": "Production", "parent_id": "root" } }``` |    no    |

## Outputs

| Name                       | Description                                   |
| -------------------------- | --------------------------------------------- |
| accounts                   | Map of created accounts and their details     |
| organization\_arn          | The AWS Organization ARN                      |
| organization\_id           | The AWS Organization ID                       |
| organizational\_units      | Map of organizational units and their details |
| root\_ou\_id               | The root organizational unit ID               |
| service\_control\_policies | Map of created service control policies       |
<!-- END_TF_DOCS -->
