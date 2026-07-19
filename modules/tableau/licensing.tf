resource "terraform_data" "license" {
  depends_on = [terraform_data.tsm_config]
  connection = local.connection

  provisioner "remote-exec" {
    inline = [
      "tsm licenses activate -k ${var.license_key}"
    ]
  }
}