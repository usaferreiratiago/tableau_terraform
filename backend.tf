# backend.tf
terraform {
  backend "s3" {
    bucket         = "your-unique-terraform-state-bucket"
    key            = "tableau/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" # Optional: for state locking
  }
}