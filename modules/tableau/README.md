# Tableau Provisioning Module

Handles the sequential bootstrapping and installation of Tableau Server on the provisioned EC2 instance.

## Execution Order

1. `bootstrap.sh`: OS updates and dependency installation.
2. `install-tableau.sh`: Installation of the RPM/deb package.
3. `configure-tsm.sh`: Initializes TSM and sets admin credentials.
4. `licensing`: Activates the server via CLI.
5. `healthcheck.sh`: Verifies the service is running.
