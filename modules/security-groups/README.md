# Security Groups Module

Provisions the network firewall rules required for a secure Tableau installation.

## Security Groups Included:
- **ALB SG**: Allows public HTTPS (443) traffic.
- **Tableau EC2 SG**: Allows traffic only from the ALB.
- **RDS SG**: Allows database traffic (5432) only from the Tableau EC2 instances.