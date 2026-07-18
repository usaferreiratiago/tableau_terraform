#!/bin/bash
# user_data/tableau.sh - Tableau Server bootstrap script

set -e

# Variables from Terraform
PROJECT_NAME="${project_name}"
NODE_INDEX="${node_index}"
LICENSE_KEY="${license_key}"
ADMIN_USER="${admin_user}"
ADMIN_PASSWORD="${admin_password}"
REPOSITORY_HOST="${repository_host}"
REPOSITORY_PORT="${repository_port}"
REPOSITORY_DBNAME="${repository_dbname}"
REPOSITORY_USER="${repository_username}"
REPOSITORY_PASS="${repository_password}"

# Logging
exec > >(tee /var/log/tableau-bootstrap.log)
exec 2>&1

echo "=========================================="
echo "Starting Tableau Server Bootstrap"
echo "Node: ${NODE_INDEX}"
echo "Project: ${PROJECT_NAME}"
echo "Timestamp: $(date)"
echo "=========================================="

# Update system
yum update -y
yum install -y wget curl git jq unzip

# Configure EBS volume if available
if [ -e /dev/sdf ]; then
    echo "Configuring EBS volume for Tableau data..."
    mkfs -t xfs /dev/sdf
    mkdir -p /var/opt/tableau
    mount /dev/sdf /var/opt/tableau
    echo "/dev/sdf /var/opt/tableau xfs defaults,nofail 0 2" >> /etc/fstab
fi

# Download Tableau Server (example - replace with actual download)
if [ ! -z "${LICENSE_KEY}" ]; then
    echo "Installing Tableau Server..."
    # This is a placeholder - replace with actual Tableau installation commands
    # Example: wget https://downloads.tableau.com/tssoftware/tableau-server-2024.1.0.x86_64.rpm
    # rpm -ivh tableau-server-*.rpm
    
    # Configure Tableau Server
    # /opt/tableau/tableau_server/packages/scripts.xx.xx.xx/initialize-tsm
    
    # Set admin user
    # tsm users create -u ${ADMIN_USER} -p ${ADMIN_PASSWORD}
    
    # Configure repository connection
    # tsm topology set-node-role -n node${NODE_INDEX} -r backgrounder,data-engine,...
    
    # Start Tableau Server
    # tsm start
else
    echo "No license key provided - skipping Tableau installation"
fi

echo "=========================================="
echo "Tableau Server bootstrap completed"
echo "Timestamp: $(date)"
echo "=========================================="