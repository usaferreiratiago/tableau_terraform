# Secrets Manager Module

Manages sensitive credentials.

## Secrets Managed:
- **db-secret**: Contains the generated PostgreSQL credentials.
- **tableau-admin**: Placeholder for initial Tableau Server admin credentials.

## Security:
- All secrets are encrypted using the project KMS key.
- DB passwords are auto-generated with 24 characters.