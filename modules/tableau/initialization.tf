resource "null_resource" "bootstrap" {
  provisioner "remote-exec" {
    script = "${local.script_path}/bootstrap.sh"
  }
}