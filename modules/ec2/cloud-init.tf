data "template_file" "user_data" {
  template = file("${path.root}/templates/cloud-init.yaml.tpl")
  vars = {
    project_name = var.project_name
  }
}