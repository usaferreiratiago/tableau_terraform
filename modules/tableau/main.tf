# Ensures the final healthcheck is performed
resource "terraform_data" "healthcheck" {
  depends_on = [terraform_data.license]
  connection = local.connection

  provisioner "remote-exec" {
    script = "${local.script_path}/healthcheck.sh"
  }
}