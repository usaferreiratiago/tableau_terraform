resource "terraform_data" "bootstrap" {
  connection = local.connection

  provisioner "remote-exec" {
    script = "${local.script_path}/bootstrap.sh"
  }
}