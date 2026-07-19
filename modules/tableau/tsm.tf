resource "terraform_data" "tsm_config" {
  depends_on = [terraform_data.install]
  connection = local.connection

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.script_path}/configure-tsm.sh",
      "${local.script_path}/configure-tsm.sh ${var.tableau_admin_user} ${var.tableau_admin_pass}"
    ]
  }
}