output "key_arn" {
  description = "The ARN of the KMS key"
  value       = module.kms_key.key_arn
}

output "key_id" {
  description = "The ID of the KMS key"
  value       = module.kms_key.key_id
}