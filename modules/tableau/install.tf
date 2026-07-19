resource "null_resource" "install" {
  depends_on = [null_resource.bootstrap]
  connection = local.connection

  provisioner "remote-exec" {
    script = "${local.script_path}/install-tableau.sh"
  }
}