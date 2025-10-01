# Variables for CodePipeline infrastructure

variable "aws_region" {
  description = "AWS region for pipeline deployment"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile for pipeline deployment"
  type        = string
  default     = "aws-identity-master"
}

variable "github_repo_owner" {
  description = "GitHub repository owner/organization"
  type        = string
}

variable "github_repo_name" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to monitor"
  type        = string
  default     = "develop"
}

variable "github_connection_arn" {
  description = "ARN of the GitHub connection (CodeStar Connection)"
  type        = string
}

variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
  default     = "aws-identity-platform-pipeline"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
