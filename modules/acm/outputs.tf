output "certificate_arn" {
  description = "The ARN of the issued ACM certificate"
  value       = aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  description = "List of domain validation options to use for DNS records"
  value       = aws_acm_certificate.cert.domain_validation_options
}