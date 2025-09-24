# Local values for the Organization module

locals {
  # Get root organizational unit ID
  root_ou_id = data.aws_organizations_organization.this.roots[0].id

  # Create map of parent IDs for OUs, replacing "root" with actual root OU ID
  ou_parent_ids = {
    for key, ou in var.organizational_units : key => (
      ou.parent_id == "root" ? local.root_ou_id : ou.parent_id
    )
  }
}