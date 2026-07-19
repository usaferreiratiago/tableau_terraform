variable "zone_id" {
  description = "The ID of the existing Route53 Hosted Zone"
  type        = string
}

variable "record_name" {
  description = "The subdomain (e.g., 'tableau' for tableau.example.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The Canonical Hosted Zone ID of the ALB"
  type        = string
}