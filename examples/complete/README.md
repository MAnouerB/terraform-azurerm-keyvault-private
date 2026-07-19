# examples/complete — Production-representative Key Vault deployment

## What this example demonstrates

- Full production-representative deployment of the Key Vault module.
- Deploys all surrounding resources the module expects as inputs: resource
  group, VNet, subnet, Private DNS Zone + VNet link, and a Log Analytics
  workspace.
- The vault is **private-only** (`public_network_access_enabled = false`) —
  reachable exclusively through its private endpoint.
- **Diagnostic settings enabled** with a dedicated Log Analytics workspace
  (`PerGB2018`, 30-day retention) receiving all supported log categories plus
  `AllMetrics`.
- **Two RBAC roles** (ADR-001): the principal running Terraform gets
  `Key Vault Administrator` automatically; an optional second principal can be
  granted `Key Vault Secrets User` via `additional_reader_object_id`.
- **Network ACLs**: `default_action = Deny`, `bypass = AzureServices`, with an
  optional public IP allowlist via `additional_ip_allowlist` for local testing.

## When to use this example

- As a reference blueprint for a production deployment.
- As a starting point for teams onboarding on the module — clone it, adapt the
  tags and RBAC to your organization, and deploy.
- As a regression testbed when developing the module.

## Prerequisites

- An Azure subscription.
- Azure CLI installed and logged in:
  ```bash
  az login
  az account set --subscription "<your-subscription-id>"
  ```
- Terraform >= 1.6.
- **Owner** or **User Access Administrator** on the target scope — required to
  create the role assignments this example provisions.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — at minimum set name_prefix
# Optionally set additional_reader_object_id and additional_ip_allowlist
terraform init
terraform plan
terraform apply
```

## Testing the deployed vault

The vault is only reachable from within the VNet or from whitelisted public IPs.

- **Option A** — whitelist your public IP via `additional_ip_allowlist` in
  `terraform.tfvars`, re-apply, then test from your machine.
- **Option B** — create a VM in the same VNet (an Azure jump box), SSH in, and
  use `az keyvault secret set/show` from there. The private DNS zone resolves the
  vault's hostname to its private IP automatically.
- **Option C** — use Azure Cloud Shell if the VNet has service endpoints wired
  (not covered by this example).

## Cost order of magnitude

- Key Vault (Standard): ~0.03 USD / 10k operations.
- Private Endpoint: ~0.008 USD / hour (~5.80 USD / month).
- Private DNS Zone: ~0.50 USD / month.
- Log Analytics workspace: ~2.30 EUR / GB ingested (a typical Key Vault audit
  workload is < 1 GB / month → < 3 EUR / month).

Order of magnitude: **~10 EUR / month** if left running with light usage.
Destroy after testing to avoid ongoing charges.

## Cleanup

```bash
terraform destroy
```

⚠️ **Soft-delete:** the vault name is reserved for the 90-day soft-delete
retention period after destroy. To redeploy with the same `name_prefix` before
then, change the prefix or wait for the window to expire — purge is blocked by
module design (purge protection is always on, ADR-003). The vault name is
`kv-<name_prefix>-<region_short>-001`.

## Inputs and Outputs

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
