#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/tableau-user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=== Tableau Server bootstrap starting $(date) ==="

############################################
# 1. OS prerequisites
############################################
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y \
  wget curl gnupg2 ca-certificates \
  software-properties-common \
  net-tools

# Basic OS tuning recommended by Tableau
cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=262144
fs.file-max=4194304
EOF
sysctl -p || true

############################################
# 2. Download and install the Tableau Server package
############################################
mkdir -p /opt/tableau_install
cd /opt/tableau_install

INSTALLER_FILE="tableau-server-installer.deb"
wget -O "$INSTALLER_FILE" "${tableau_installer_url}"

dpkg -i "$INSTALLER_FILE" || apt-get install -f -y

############################################
# 3. Prepare registration file
############################################
cat > /opt/tableau_install/registration.json <<'EOF'
${registration_json}
EOF

############################################
# 4. Run the automated initialize-tsm script
#
# NOTE: The exact flags of initialize-tsm / tsm can change between
# Tableau Server releases. Verify against the official documentation
# for your target version before relying on this in production:
# https://help.tableau.com/current/server-linux/en-us/automated_installer.htm
############################################
INIT_SCRIPT_DIR=$(find /opt/tableau/tableau_server -maxdepth 1 -type d -name "packages.*" | head -n1)
INIT_SCRIPT=$(find /opt/tableau/tableau_server -path "*/scripts.*/initialize-tsm" | head -n1)

if [ -z "$INIT_SCRIPT" ]; then
  echo "ERROR: could not locate initialize-tsm script after install" >&2
  exit 1
fi

FQDN="${tableau_server_fqdn}"
if [ -z "$FQDN" ]; then
  FQDN=$(hostname -f 2>/dev/null || hostname)
fi

"$INIT_SCRIPT" \
  --accepteula \
  -s "$FQDN" \
  --registration-file /opt/tableau_install/registration.json \
  --username "${tableau_admin_username}" \
  --password "${tableau_admin_password}" \
  --no-phonehome \
  --no-prompt

# Source the environment variables initialize-tsm just configured (tsm CLI path etc.)
source /etc/profile.d/tableau_server.sh || true

############################################
# 5. Apply license (if provided) and start the server
############################################
%{ if tableau_license_key != "" ~}
/opt/tableau/tsm/bin/tsm licenses activate -k "${tableau_license_key}" || true
%{ endif ~}

/opt/tableau/tsm/bin/tsm register --username "${tableau_admin_username}" --password "${tableau_admin_password}" --registration-file /opt/tableau_install/registration.json || true

/opt/tableau/tsm/bin/tsm initialize --start-server --request-timeout 1800 --username "${tableau_admin_username}" --password "${tableau_admin_password}" || true

/opt/tableau/tsm/bin/tsm status -v || true

############################################
# 6. Create the initial Tableau Server administrator user
############################################
/opt/tableau/tsm/bin/tabcmd initialuser \
  --server "https://localhost" \
  --username "${tableau_admin_username}" \
  --password "${tableau_admin_password}" \
  --no-certcheck || true

echo "=== Tableau Server bootstrap finished $(date) ==="
