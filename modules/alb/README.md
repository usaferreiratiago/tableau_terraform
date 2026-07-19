# ALB Module

Provisions an Application Load Balancer to front the Tableau Server.

## Configuration:
- **Port 80**: Redirects all traffic to 443.
- **Port 443**: Terminates SSL and forwards traffic to the EC2 target group.
- **Health Checks**: Configured to monitor the root path.