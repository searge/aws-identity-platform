locals {
  # Organizational units from variable or default mapping
  ou_names = length(var.organizational_units) > 0 ? {
    for key, ou in var.organizational_units : key => ou.name
    } : {
    dev  = "Development"
    prod = "Production"
  }
}
