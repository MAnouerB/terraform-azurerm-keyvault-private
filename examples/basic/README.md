# examples/basic — Minimal Key Vault with public network access

## What this example demonstrates

- Minimal deployment of the Key Vault module.
- Deploys the required surrounding resources (resource group, VNet, subnet,
  Private DNS Zone + VNet link) that the module expects as inputs.
- The vault has **public network access ENABLED** — the private endpoint is
  still created (per module ADR-002) but is not the sole entry point.
- Diagnostic settings are **disabled** (no Log Analytics workspace, to keep the
  example minimal).
- **No role assignments** — consumers grant themselves data-plane access after
  apply.

## ⚠️ Not for production use

This pattern is for quick **dev/test** exploration only. The vault is reachable
from the public internet, subject to its network ACLs. **For production, use
[`examples/complete`](../complete/)** which demonstrates the fully private,
production-grade pattern.

Compared to a production deployment, this example intentionally omits:

- Private-only access (`public_network_access_enabled = false`).
- Diagnostic settings streaming to Log Analytics.
- RBAC role assignments to principals.
- Restrictive, explicitly-whitelisted network ACLs.

## Prerequisites

- An Azure subscription.
- Azure CLI installed and logged in:
  ```bash
  az login
  az account set --subscription "<your-subscription-id>"
  ```
- Terraform >= 1.6.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars if needed
terraform init
terraform plan
terraform apply
```

## Cost order of magnitude

- Key Vault (Standard): ~0.03 USD / 10k operations.
- Private Endpoint: ~0.008 USD / hour.
- Private DNS Zone: ~0.50 USD / month.

Order of magnitude: **< 1 USD/day** if the vault sits idle. Destroy after
testing to avoid ongoing charges and the soft-delete retention on the vault name.

## Cleanup

```bash
terraform destroy
```

⚠️ **Soft-delete:** the vault name is reserved for the soft-delete retention
period (90 days per module default) after destroy. If you plan to re-deploy with
the same `name_prefix`, either wait for the soft-delete window to expire or purge
manually:

```bash
az keyvault purge --name kv-<name_prefix>-<region_short>-001
```

## Inputs and Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
