resource "terraform_data" "install" {
  depends_on = [terraform_data.bootstrap]
  connection = local.connection

  provisioner "remote-exec" {
    script = "${local.script_path}/install-tableau.sh"
  }
}