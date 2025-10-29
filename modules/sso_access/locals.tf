# Local values for IAM Identity Center access management

locals {
  # Convert flat assignments list to map for efficient for_each iteration
  # Already flattened at root level using setproduct (Cartesian product)
  # Example: [{principal_name: "Admins", permission_set: "Admin", account_name: "dev"}]
  # Becomes: {"Admins-Admin-dev" => {principal_name: "Admins", ...}}
  assignments_map = {
    for assignment in var.account_assignments :
    "${assignment.principal_name}-${assignment.permission_set}-${assignment.account_name}" => assignment
  }

  # Flatten managed policy attachments (Cartesian product: permission_sets × policies)
  # Step 1: Create flat list with unique keys
  # Example: {Admin: {managed_policy_arns: ["arn:aws:iam::aws:policy/AdministratorAccess"]}}
  # Becomes: [{permission_set: "Admin", policy_arn: "arn:...", key: "Admin--arn-..."}]
  policy_attachments_list = flatten([
    for ps_key, ps in var.permission_sets : [
      for policy_arn in ps.managed_policy_arns : {
        permission_set = ps_key
        policy_arn     = policy_arn
        key            = "${ps_key}--${replace(policy_arn, ":", "-")}" # Colons invalid in resource keys
      }
    ]
  ])

  # Step 2: Convert to map for efficient resource creation
  # List → Map conversion for terraform for_each (requires unique keys)
  managed_policy_attachments = {
    for item in local.policy_attachments_list : item.key => item
  }

  # Flatten customer managed policy attachments (Cartesian product: permission_sets × customer policies)
  # Step 1: Create flat list with unique keys
  # Example: {Admin: {customer_managed_policy_references: [{name: "CustomPolicy", path: "/"}]}}
  # Becomes: [{permission_set: "Admin", policy_name: "CustomPolicy", policy_path: "/", key: "Admin--CustomPolicy"}]
  customer_policy_attachments_list = flatten([
    for ps_key, ps in var.permission_sets : [
      for policy in ps.customer_managed_policy_references : {
        permission_set = ps_key
        policy_name    = policy.name
        policy_path    = policy.path
        key            = "${ps_key}--${policy.name}"
      }
    ]
  ])

  # Step 2: Convert to map for efficient resource creation
  # List → Map conversion for terraform for_each (requires unique keys)
  customer_managed_policy_attachments = {
    for item in local.customer_policy_attachments_list : item.key => item
  }
}
