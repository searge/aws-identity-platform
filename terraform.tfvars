aws_region  = "us-east-1"
environment = "dev"

identity_center_users = {
  "johndoe" = {
    given_name  = "John"
    family_name = "Doe"
    email       = "your-unique-email+john.doe@example.com"
  }
}

identity_center_groups = {
  "Developers" = {
    description = "Application Developers"
    members     = ["johndoe"]
  }
}

permission_sets = {
  "ViewOnly" = {
    description         = "Provides view-only access to AWS services and resources."
    session_duration    = "PT8H"
    managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }
}

account_assignments = [
  {
    principal_name = "Developers"
    principal_type = "GROUP"
    account_name   = "sandbox_dev"
    permission_set = "ViewOnly"
  }
]
