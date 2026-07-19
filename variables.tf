variable "project_name" {

  type        = string
  description = "Project name"

  default = "tableau"

}

variable "environment" {

  type        = string
  description = "Deployment environment"

  default = "dev"

}

variable "aws_region" {

  type = string

  default = "us-east-1"

}

variable "owner" {

  type = string

  default = "Tiago Ferreira"

}

variable "vpc_cidr" {

  type = string

  default = "10.0.0.0/16"

}

variable "instance_type" {

  type = string

  default = "m6i.xlarge"

}

variable "tableau_version" {

  type = string

  default = "latest"

}