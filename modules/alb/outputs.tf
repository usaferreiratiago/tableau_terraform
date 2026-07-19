output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = module.alb.target_groups["tableau"].arn
}