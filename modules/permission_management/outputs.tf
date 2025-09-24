# Outputs from the Permission Management module

output "account_assignments" {
  description = "Map of created account assignments"
  value = {
    for key, assignment in aws_ssoadmin_account_assignment.this : key => {
      account_id         = assignment.target_id
      permission_set_arn = assignment.permission_set_arn
      principal_id       = assignment.principal_id
      principal_type     = assignment.principal_type
    }
  }
}

output "access_review_topic_arn" {
  description = "ARN of the SNS topic for access review notifications"
  value       = aws_sns_topic.access_review.arn
}

output "access_review_lambda_function_name" {
  description = "Name of the Lambda function for access reviews"
  value       = aws_lambda_function.access_review.function_name
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}