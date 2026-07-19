# Terraform Tableau AWS

Production-ready Infrastructure as Code for deploying Tableau Server on AWS using Terraform.

---

## Features

- Terraform 1.13+
- AWS Provider v6
- Multi-environment (Dev / QA / Prod)
- Modular architecture
- VPC
- Private/Public Subnets
- Internet Gateway
- NAT Gateway
- Application Load Balancer
- ACM SSL
- Route53
- EC2
- Auto Scaling ready
- IAM Least Privilege
- Security Groups
- AWS Systems Manager
- Secrets Manager
- CloudWatch
- AWS Backup
- GitHub Actions CI/CD
- Remote Terraform State
- Tableau automated installation

---

## Repository Structure

```
terraform-tableau-aws/
│
├── documents/
├── environments/
├── modules/
├── scripts/
├── terraform/
└── .github/
```

---

## Requirements

- Terraform >= 1.13
- AWS CLI
- Git
- Tableau Server Installer
- AWS Account

---

## Initialize

```bash
terraform init
```

Validate

```bash
terraform validate
```

Plan

```bash
terraform plan
```

Apply

```bash
terraform apply
```

Destroy

```bash
terraform destroy
```

---

## Architecture

```
Internet
    │
Route53
    │
ACM
    │
Application Load Balancer
    │
Private EC2
    │
Tableau Server
    │
Amazon EBS
```

---

## Modules

| Module | Description |
|---------|-------------|
| networking | AWS VPC |
| iam | IAM Roles |
| security-groups | Firewall Rules |
| ec2 | Compute |
| tableau | Tableau Installation |
| alb | Load Balancer |
| acm | SSL |
| route53 | DNS |
| cloudwatch | Monitoring |
| ssm | Systems Manager |
| secrets-manager | Credentials |
| backup | AWS Backup |

---

## License

MIT
