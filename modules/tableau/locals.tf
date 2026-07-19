locals {
  script_path = "${path.module}/../../scripts"
  connection = {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = var.instance_ip
  }
}