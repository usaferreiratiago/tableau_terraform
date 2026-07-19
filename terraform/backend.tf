terraform {

  backend "s3" {

    bucket         = "terraform-tableau-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-lock"

    encrypt = true

  }

}