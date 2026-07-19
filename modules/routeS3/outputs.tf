output "fqdn" {
  description = "The fully qualified domain name of the Tableau Server"
  value       = aws_route53_record.tableau_dns.fqdn
}