terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket" # Change this
    key            = "prod/tableau.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"       # Change this
  }
}