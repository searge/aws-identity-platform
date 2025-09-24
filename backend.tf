terraform {
  backend "local" {
    # Configuration via backend.tfvars files
    # Example usage:
    # terraform init -backend-config=env/dev/backend.tfvars
    # terraform init -backend-config=env/prod/backend.tfvars
  }
}
