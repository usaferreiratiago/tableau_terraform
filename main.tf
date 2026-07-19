module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  
  # VPC configuration placeholder
  vpc_cidr = "10.0.0.0/16"
}