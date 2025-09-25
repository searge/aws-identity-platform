# Permission Management Module

This module handles the lifecycle management of access permissions and implements automated access review processes. It manages account assignments and provides governance automation for Identity Center permissions.

## Features

- Manages SSO account assignments for users and groups
- Implements automated access review workflows
- Creates Lambda functions for permission lifecycle automation
- Sets up SNS notifications for access review alerts
- Configures CloudWatch Events for scheduled reviews

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.10 |
| archive   | ~> 2.7  |
| aws       | ~> 5.94 |

## Providers

| Name    | Version |
| ------- | ------- |
| archive | ~> 2.7  |
| aws     | ~> 5.94 |

## Resources

| Name                                                                                                                                             | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudwatch_event_rule.access_review](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)     | resource    |
| [aws_cloudwatch_event_target.access_review](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource    |
| [aws_iam_role.lambda_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                            | resource    |
| [aws_iam_role_policy.lambda_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)              | resource    |
| [aws_lambda_function.access_review](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                 | resource    |
| [aws_lambda_permission.access_review](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)             | resource    |
| [aws_sns_topic.access_review](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                             | resource    |
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment)  | resource    |
| [archive_file.access_review_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                     | data source |

## Inputs

| Name                     | Description                                         | Type                                                                                                                  | Default               | Required |
| ------------------------ | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- | --------------------- | :------: |
| access\_review\_schedule | Schedule for access reviews (cron expression)       | `string`                                                                                                              | `"cron(0 9 1 * ? *)"` |    no    |
| account\_assignments     | Map of account assignments                          | ```map(object({ account_id = string permission_set_name = string principal_id = string principal_type = string }))``` | `{}`                  |    no    |
| common\_tags             | Common tags to apply to all resources               | `map(string)`                                                                                                         | `{}`                  |    no    |
| environment              | Environment name (dev/prod)                         | `string`                                                                                                              | n/a                   |   yes    |
| identity\_store\_id      | The Identity Store ID from IAM Identity Center      | `string`                                                                                                              | n/a                   |   yes    |
| permission\_sets         | Map of permission sets from identity\_center module | `any`                                                                                                                 | `{}`                  |    no    |
| sso\_instance\_arn       | The ARN of the SSO instance                         | `string`                                                                                                              | n/a                   |   yes    |

## Outputs

| Name                                   | Description                                          |
| -------------------------------------- | ---------------------------------------------------- |
| access\_review\_lambda\_function\_name | Name of the Lambda function for access reviews       |
| access\_review\_topic\_arn             | ARN of the SNS topic for access review notifications |
| account\_assignments                   | Map of created account assignments                   |
| lambda\_execution\_role\_arn           | ARN of the Lambda execution role                     |
<!-- END_TF_DOCS -->
