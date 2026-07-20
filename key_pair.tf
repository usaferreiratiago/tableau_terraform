# If the caller did not provide an existing key pair name, generate one and
# save the private key locally so they can SSH into the instance.

resource "tls_private_key" "generated" {
  count     = var.key_pair_name == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  count      = var.key_pair_name == null ? 1 : 0
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.generated[0].public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  count           = var.key_pair_name == null ? 1 : 0
  filename        = "${path.module}/${var.project_name}-key.pem"
  content         = tls_private_key.generated[0].private_key_pem
  file_permission = "0400"
}

locals {
  key_pair_name = var.key_pair_name != null ? var.key_pair_name : aws_key_pair.generated[0].key_name
}
