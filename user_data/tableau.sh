#!/bin/bash
# user_data/tableau.sh - Tableau Server bootstrap script

set -e

# Variables from Terraform
PROJECT_NAME="${project_name:-tableau}"
NODE_INDEX="${node_index:-1}"
LICENSE_KEY="${license_key:-}"
ADMIN_USER="${admin_user:-admin}"
ADMIN_PASSWORD="${admin_password:-}"
REPOSITORY_HOST="${repository_host:-}"
REPOSITORY_PORT="${repository_port:-5432}"
REPOSITORY_DBNAME="${repository_dbname:-tableau}"
REPOSITORY_USER="${repository_username:-}"
REPOSITORY_PASS="${repository_password:-}"

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

# Check if license key is provided
if [ -z "${LICENSE_KEY}" ]; then
    echo "WARNING: No license key provided. Tableau will not be installed."
    echo "Set TF_VAR_tableau_license_key environment variable to install."
    exit 0
fi

# Download Tableau Server (EXAMPLE - REPLACE WITH ACTUAL DOWNLOAD)
echo "Downloading Tableau Server..."
# Replace with actual Tableau download URL
# wget -O /tmp/tableau-server.rpm "https://downloads.tableau.com/tssoftware/tableau-server-2024.1.0.x86_64.rpm"

# Install Tableau Server
# rpm -ivh /tmp/tableau-server.rpm

# Initialize Tableau Server
# /opt/tableau/tableau_server/packages/scripts.xx.xx.xx/initialize-tsm

# Create admin user
# if [ ! -z "${ADMIN_USER}" ] && [ ! -z "${ADMIN_PASSWORD}" ]; then
#     tsm users create -u ${ADMIN_USER} -p ${ADMIN_PASSWORD}
# fi

# Configure repository if provided
# if [ ! -z "${REPOSITORY_HOST}" ]; then
#     echo "Configuring external repository: ${REPOSITORY_HOST}"
#     tsm topology set-repository-connection \
#         -host ${REPOSITORY_HOST} \
#         -port ${REPOSITORY_PORT} \
#         -dbname ${REPOSITORY_DBNAME} \
#         -username ${REPOSITORY_USER} \
#         -password ${REPOSITORY_PASS}
# fi

# Configure node role
# tsm topology set-node-role -n node${NODE_INDEX} -r backgrounder,data-engine,interactive,gateway

# Start Tableau Server
# tsm start

echo "=========================================="
echo "Tableau Server bootstrap completed"
echo "Timestamp: $(date)"
echo "=========================================="