variable "tableau_admin_password" {
  description = "Password for the Tableau administrator account"
  type        = string
  sensitive   = true
}

variable "tableau_admin_username" {
  description = "Username for the Tableau administrator account"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key used for remote access"
  type        = string
}

locals {
  # Connection details for the remote-exec provisioner
  connection = {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.ssh_private_key_path) # Ensure this is passed as a variable
    host        = var.instance_private_ip
  }
  
  script_path = "/home/ec2-user/scripts"
}

resource "terraform_data" "tsm_config" {
  depends_on = [terraform_data.install]
  
  provisioner "remote-exec" {
    connection {
      type        = local.connection.type
      user        = local.connection.user
      private_key = local.connection.private_key
      host        = local.connection.host
    }

    inline = [
      "chmod +x ${local.script_path}/configure-tsm.sh",
      "${local.script_path}/configure-tsm.sh ${var.tableau_admin_username} ${var.tableau_admin_password}"
    ]
  }
}