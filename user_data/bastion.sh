#!/bin/bash
# user_data/bastion.sh - Bastion host bootstrap script

set -e

PROJECT_NAME="${project_name}"

echo "=========================================="
echo "Starting Bastion Host Bootstrap"
echo "Project: ${PROJECT_NAME}"
echo "Timestamp: $(date)"
echo "=========================================="

# Update system
yum update -y
yum install -y wget curl git jq unzip tmux htop

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl if needed
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl && mv kubectl /usr/local/bin/

# Install terraform if needed
# wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
# unzip terraform_1.6.0_linux_amd64.zip && mv terraform /usr/local/bin/

# Configure SSH agent forwarding
echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config
systemctl restart sshd

echo "=========================================="
echo "Bastion Host bootstrap completed"
echo "Timestamp: $(date)"
echo "=========================================="