module "tableau" {

  source = "github.com/usaferreiratiago/tableau-terraform"

  project_name  = "analytics"
  environment   = "production"
  domain_name   = "tableau.company.com"
  instance_count = 3
  instance_type = "m6i.2xlarge"

}