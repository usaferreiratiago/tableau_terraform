variable "project_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "key_pair_name" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "associate_public_ip" {
  type = bool
}

variable "root_volume_size_gb" {
  type = number
}

variable "root_volume_type" {
  type = string
}

variable "enable_termination_protection" {
  type = bool
}

variable "user_data" {
  type = string
}

variable "tags" {
  type = map(string)
}
