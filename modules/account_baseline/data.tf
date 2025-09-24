# Data sources for the Account Baseline module

# Current region
data "aws_region" "current" {}

# Current caller identity
data "aws_caller_identity" "current" {}