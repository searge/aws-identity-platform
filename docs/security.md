# Security Guidelines

## Access Control Model

### Group-Based Access (Best Practice)

**This project follows AWS best practices by granting permissions to groups, not individual users.**

**How it works:**

```txt
User → Group → Permission Set → AWS Account
```

**Example:**

1. User `dereban` is added to group `SuperAdmins` ([config/groups.yaml](../config/groups.yaml))
2. Group `SuperAdmins` is granted `AdministratorAccess` permission set ([config/account_assignments.yaml](../config/account_assignments.yaml))
3. Permission set is assigned to specific AWS accounts (sandbox, prod, audit)

**Why groups, not users?**

✅ **Easier management** - Add user to group once, they inherit all permissions
✅ **Consistency** - All users in same role get identical access
✅ **Auditability** - Review group memberships instead of individual assignments
✅ **Scalability** - Onboard new users in seconds by adding to existing groups

**What we DON'T do:**

❌ Direct user-to-permission assignments
❌ Permission sets assigned to individual users
❌ User-specific access rules

**Where to look:**

- **Groups defined**: [`config/groups.yaml`](../config/groups.yaml)
- **Users assigned to groups**: [`config/groups.yaml`](../config/groups.yaml) (members field)
- **Groups granted permissions**: [`config/account_assignments.yaml`](../config/account_assignments.yaml) (principal_type: GROUP)

---

## Core Security Principles

**Zero Trust**: All access requires verification, regardless of location or user status.
**Least Privilege**: Users get minimum permissions needed for their role.
**Defense in Depth**: Multiple security layers protect against threats.

## Authentication & Authorization

### Multi-Factor Authentication (MFA)

- **Required** for all administrative access
- **Hardware tokens** recommended for privileged accounts
- **TOTP apps** acceptable for standard users

### Permission Sets

```pro
Admin Access     → Full account access (break-glass only)
Developer Access → Development resources + limited production read
ReadOnly Access  → View-only across all accounts
```

### Session Management

- **Maximum session duration**: 8 hours for admins, 12 hours for developers
- **Idle timeout**: 2 hours
- **Re-authentication required** for sensitive operations

## Security Controls

### Service Control Policies (SCPs)

- **Root access denial** - Prevents root user actions
- **MFA enforcement** - Requires MFA for console access
- **Encryption enforcement** - Mandates encryption at rest

### Monitoring & Logging

- **CloudTrail** enabled on all accounts
- **GuardDuty** active for threat detection
- **Config** monitors configuration compliance
- **Real-time alerts** for privilege escalation attempts

### Network Security

- **Account isolation** as primary boundary
- **Cross-account roles** for controlled access
- **VPC endpoints** for private AWS service access

## Compliance & Auditing

### Access Reviews

- **Quarterly** permission reviews
- **Automated** unused permission detection
- **Just-in-time** access for temporary needs

### Audit Requirements

- **90-day** CloudTrail retention minimum
- **Immutable** log storage in dedicated audit account
- **Access patterns** analysis and anomaly detection

### Policy Validation

- **Terraform tests** validate security configurations
- **Policy simulation** before deployment
- **Drift detection** for unauthorized changes

## Security Automation

### Deployment Security

```bash
# Pre-deployment checks
terraform plan -var-file=env/prod/terraform.tfvars | grep -i "security\|policy"

# Validate configurations
terraform test

# Apply with approval
terraform apply "plan.tfplan"
```

### Incident Response

1. **Detect** - Automated alerts trigger investigation
2. **Isolate** - Account-level containment
3. **Investigate** - CloudTrail analysis
4. **Remediate** - Terraform-managed recovery
5. **Document** - Update security procedures

## Quick Reference

| Threat | Control | Implementation |
|--------|---------|----------------|
| Privilege Escalation | SCPs | Service Control Policies (planned) |
| Unauthorized Access | MFA + Identity Center | `modules/identity_center/` |
| Data Breach | Encryption + Monitoring | CloudTrail + GuardDuty + Config |
| Insider Threat | Access Reviews | Quarterly review of `config/account_assignments.yaml` |

---
*Security is everyone's responsibility. When in doubt, ask the security team.*
