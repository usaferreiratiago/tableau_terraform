variable "ssh_key_path" {
  description = "Path to the SSH private key for connecting to the Tableau instance."
  type        = string
}

locals {
  script_path = "${path.module}/../../scripts"
  connection = {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_key_path)
    host        = var.instance_ip
  }
}