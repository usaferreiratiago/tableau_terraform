variable "instance_ip" {
  description = "IP address of the Tableau instance"
  type        = string
}

output "deployment_status" {
  value = "Tableau installation completed successfully on ${var.instance_ip}"
}