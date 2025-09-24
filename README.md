# AWS Identity Platform

A Terraform-based solution for centralized identity and access management across multi-account AWS environments.

## 🎯 What This Does

- **AWS Organizations**: Manages master account, member accounts, and organizational units
- **IAM Identity Center**: Provides single sign-on and centralized permission management
- **Account Baseline**: Standardizes configuration for new AWS accounts
- **Access Control**: Automates permission assignments across all accounts

## 📁 Structure

```bash
modules/
├── organization/          # AWS Organizations management
├── identity_center/       # IAM Identity Center (SSO)
├── account_baseline/      # Account standardization
└── permission_management/ # Access control automation

env/
├── dev/                   # Development environment
└── prod/                  # Production environment

policies/
├── service_control/       # Organization-wide SCPs
└── permission_sets/       # Identity Center permissions
```

## 🛡️ Security First

- **Least Privilege**: Minimal required permissions only
- **MFA Required**: Multi-factor authentication for admin access
- **Centralized Logging**: All identity events tracked and monitored
- **Regular Reviews**: Automated access auditing and compliance checks

## 📋 Prerequisites

- AWS CLI configured with master account access
- Terraform >= 1.10
- New AWS account (becomes organization master)

## 📚 Documentation

- [Architecture Overview](docs/architecture.md)
- [Security Guidelines](docs/security.md)
- [Deployment Guide](docs/deployment.md)
- [Module Documentation](modules/)

## 🎯 For Teams Who Need

- [x] Multi-account AWS management
- [x] Scalable identity management
- [x] Centralized access control
- [x] Compliance automation
