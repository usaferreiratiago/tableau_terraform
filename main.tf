locals {
  registration_json = templatefile("${path.module}/templates/registration.json.tpl", {
    first_name = var.tableau_registration.first_name
    last_name  = var.tableau_registration.last_name
    email      = var.tableau_registration.email
    company    = var.tableau_registration.company
    title      = var.tableau_registration.title
    department = var.tableau_registration.department
    industry   = var.tableau_registration.industry
    phone      = var.tableau_registration.phone
    city       = var.tableau_registration.city
    state      = var.tableau_registration.state
    zip        = var.tableau_registration.zip
    country    = var.tableau_registration.country
  })

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    tableau_installer_url  = var.tableau_installer_url
    registration_json      = local.registration_json
    tableau_admin_username = var.tableau_admin_username
    tableau_admin_password = var.tableau_admin_password
    tableau_license_key    = var.tableau_license_key
    tableau_server_fqdn    = var.tableau_server_fqdn
  })
}

module "tableau_ec2" {
  source = "./modules/ec2_tableau"

  project_name                  = var.project_name
  ami_id                        = local.ami_id
  instance_type                 = var.instance_type
  subnet_id                     = local.selected_subnet_id
  security_group_ids            = [aws_security_group.tableau.id]
  key_pair_name                 = local.key_pair_name
  iam_instance_profile          = aws_iam_instance_profile.tableau_instance_profile.name
  associate_public_ip           = var.associate_public_ip
  root_volume_size_gb           = var.root_volume_size_gb
  root_volume_type              = var.root_volume_type
  enable_termination_protection = var.enable_termination_protection
  user_data                     = local.user_data
  tags                          = var.tags
}
