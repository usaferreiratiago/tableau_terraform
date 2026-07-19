# IAM Module

Provisions the IAM Role and Instance Profile required for Tableau Server EC2 instances.

## Policies Attached:
- `AmazonSSMManagedInstanceCore` (SSM access)
- `CloudWatchAgentServerPolicy` (CloudWatch Logs/Metrics)
- Custom Secrets Manager Access
- Custom KMS Decryption Access