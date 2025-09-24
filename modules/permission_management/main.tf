# Permission Management module - manages access lifecycle and automation

# Account assignments for permission sets
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.account_assignments

  instance_arn       = var.sso_instance_arn
  permission_set_arn = local.permission_set_arns[each.value.permission_set_name]

  principal_id   = each.value.principal_id
  principal_type = each.value.principal_type

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_execution" {
  name = "identity-platform-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "identity-platform-lambda-execution-role"
    Type = "IAMRole"
  })
}

# IAM policy for Lambda execution
resource "aws_iam_role_policy" "lambda_execution" {
  name = "identity-platform-lambda-execution-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "sso:ListAccountAssignments",
          "sso:ListPermissionSets",
          "sso:DescribePermissionSet",
          "identitystore:ListUsers",
          "identitystore:ListGroups",
          "identitystore:DescribeUser",
          "identitystore:DescribeGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.access_review.arn
      }
    ]
  })
}

# SNS topic for access review notifications
resource "aws_sns_topic" "access_review" {
  name = "identity-platform-access-review-${var.environment}"

  tags = merge(var.common_tags, {
    Name = "identity-platform-access-review-${var.environment}"
    Type = "SNSTopic"
  })
}

# CloudWatch Event Rule for periodic access reviews
resource "aws_cloudwatch_event_rule" "access_review" {
  name                = "identity-platform-access-review-${var.environment}"
  description         = "Trigger access review automation"
  schedule_expression = var.access_review_schedule

  tags = merge(var.common_tags, {
    Name = "identity-platform-access-review-${var.environment}"
    Type = "CloudWatchEventRule"
  })
}

# Lambda function for access review automation
resource "aws_lambda_function" "access_review" {
  filename         = data.archive_file.access_review_lambda.output_path
  source_code_hash = data.archive_file.access_review_lambda.output_base64sha256
  function_name    = "identity-platform-access-review-${var.environment}"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  timeout          = 300

  environment {
    variables = {
      SSO_INSTANCE_ARN  = var.sso_instance_arn
      IDENTITY_STORE_ID = var.identity_store_id
      SNS_TOPIC_ARN     = aws_sns_topic.access_review.arn
      ENVIRONMENT       = var.environment
    }
  }

  tags = merge(var.common_tags, {
    Name = "identity-platform-access-review-${var.environment}"
    Type = "LambdaFunction"
  })
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "access_review" {
  rule      = aws_cloudwatch_event_rule.access_review.name
  target_id = "AccessReviewLambdaTarget"
  arn       = aws_lambda_function.access_review.arn
}

# Lambda permission for CloudWatch Events
resource "aws_lambda_permission" "access_review" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.access_review.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.access_review.arn
}

# Create a simple Lambda deployment package
data "archive_file" "access_review_lambda" {
  type        = "zip"
  output_path = "access_review_lambda.zip"

  source {
    content  = <<EOF
import json
import boto3
import os
from datetime import datetime

def handler(event, context):
    """
    Lambda function to perform automated access reviews
    """
    sso_admin = boto3.client('sso-admin')
    identity_store = boto3.client('identitystore')
    sns = boto3.client('sns')

    sso_instance_arn = os.environ['SSO_INSTANCE_ARN']
    identity_store_id = os.environ['IDENTITY_STORE_ID']
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    environment = os.environ['ENVIRONMENT']

    try:
        # List all permission sets
        permission_sets = sso_admin.list_permission_sets(
            InstanceArn=sso_instance_arn
        )

        review_data = []

        for ps_arn in permission_sets['PermissionSets']:
            # Get permission set details
            ps_details = sso_admin.describe_permission_set(
                InstanceArn=sso_instance_arn,
                PermissionSetArn=ps_arn
            )

            # List account assignments for this permission set
            assignments = sso_admin.list_account_assignments(
                InstanceArn=sso_instance_arn,
                PermissionSetArn=ps_arn,
                AccountId='214181534067'  # Management account
            )

            review_data.append({
                'permission_set': ps_details['PermissionSet']['Name'],
                'assignments': len(assignments['AccountAssignments']),
                'description': ps_details['PermissionSet'].get('Description', 'No description')
            })

        # Prepare notification message
        message = f"""
Access Review Report for {environment.upper()} Environment
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

Permission Set Summary:
"""

        for item in review_data:
            message += f"- {item['permission_set']}: {item['assignments']} assignments\n"
            message += f"  Description: {item['description']}\n\n"

        message += "\nPlease review these assignments and ensure they comply with your organization's access policies."

        # Send notification
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject=f'Access Review Report - {environment.upper()}',
            Message=message
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Access review completed successfully',
                'permission_sets_reviewed': len(review_data)
            })
        }

    except Exception as e:
        print(f"Error during access review: {str(e)}")

        # Send error notification
        sns.publish(
            TopicArn=sns_topic_arn,
            Subject=f'Access Review Error - {environment.upper()}',
            Message=f'Error occurred during access review: {str(e)}'
        )

        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Access review failed',
                'error': str(e)
            })
        }
EOF
    filename = "index.py"
  }
}