# Account Baseline Module

This module applies security and compliance baselines to AWS accounts. It implements essential security services and logging capabilities to ensure accounts meet organizational security standards.

## Features

- Configures AWS CloudTrail for audit logging
- Sets up Amazon GuardDuty for threat detection
- Implements AWS Config for compliance monitoring
- Creates secure S3 buckets with encryption and versioning
- Establishes IAM roles for service integrations

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

| Name                                                                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)                                                                               | resource    |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder)                                         | resource    |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel)                                                     | resource    |
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)                                                               | resource    |
| [aws_iam_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                                 | resource    |
| [aws_iam_role_policy_attachment.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                             | resource    |
| [aws_s3_bucket.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                               | resource    |
| [aws_s3_bucket_policy.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                             | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                               | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                                 | data source |

## Inputs

| Name                        | Description                           | Type          | Default                          | Required |
| --------------------------- | ------------------------------------- | ------------- | -------------------------------- | :------: |
| account\_id                 | AWS Account ID                        | `string`      | n/a                              |   yes    |
| aws\_region                 | AWS region                            | `string`      | `"us-east-1"`                    |    no    |
| cloudtrail\_name            | Name for the CloudTrail               | `string`      | `"identity-platform-cloudtrail"` |    no    |
| cloudtrail\_s3\_key\_prefix | S3 key prefix for CloudTrail logs     | `string`      | `"AWSLogs"`                      |    no    |
| common\_tags                | Common tags to apply to all resources | `map(string)` | `{}`                             |    no    |
| enable\_config              | Enable AWS Config                     | `bool`        | `true`                           |    no    |
| enable\_guardduty           | Enable GuardDuty                      | `bool`        | `true`                           |    no    |

## Outputs

| Name                     | Description                               |
| ------------------------ | ----------------------------------------- |
| cloudtrail\_arn          | The ARN of the CloudTrail                 |
| cloudtrail\_bucket\_name | Name of the S3 bucket for CloudTrail logs |
| config\_bucket\_name     | Name of the S3 bucket for Config          |
| config\_recorder\_name   | Name of the Config configuration recorder |
| guardduty\_detector\_id  | The ID of the GuardDuty detector          |
<!-- END_TF_DOCS -->
