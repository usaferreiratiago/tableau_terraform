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
  
  connection = local.connection

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.script_path}/configure-tsm.sh",
      "${local.script_path}/configure-tsm.sh ${var.tableau_admin_username} ${var.tableau_admin_password}"
    ]
  }
}