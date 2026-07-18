# backend.tf - Remote state configuration
terraform {
  backend "s3" {
    # These values should be overridden via backend-config or replaced with your own
    bucket         = "your-terraform-state-bucket"  # REPLACE ME
    key            = "tableau/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # Optional: for state locking
  }
}

# Note: If you don't want to use remote backend yet, comment out the entire block above
# and use local state instead:
# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }