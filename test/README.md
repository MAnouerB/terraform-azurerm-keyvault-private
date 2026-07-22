# Terratest suite

Automated end-to-end tests for the `terraform-azurerm-keyvault-private` module.

## What is tested

The `TestKeyVaultPrivateComplete` test deploys `examples/complete/` on
Azure, then asserts:

- The Key Vault, private endpoint, and Log Analytics workspace exist and
  are queryable via the Azure SDK
- The Key Vault name follows the module's naming convention (`kv-<prefix>-<region_short>-001`)
- RBAC authorization is enabled (ADR-001)
- Purge protection is enabled (ADR-003)
- Public network access is disabled (ADR-002 posture on the `complete` example)
- Soft delete retention is 90 days (module default, maximum recovery window)
- Network ACLs default action is `Deny`, bypass allows `AzureServices`
- Module-managed tags (`managed_by`, `module_source`, `module_version`) are applied
- User-supplied tags from the example (`environment`, `example`) are merged and present
- The private endpoint targets the Key Vault with the `vault` subresource group
- The private endpoint's private IP is within the subnet CIDR

## Out of scope for v0.1.0

Data-plane operations (secret/key/certificate CRUD) are **not** tested.
The vault is private-only, and validating data-plane access requires a
jump box VM in the same VNet. This is planned for v0.2.0.

The `basic` example is not tested — it demonstrates a non-production
pattern (public network access) and is not the module's canonical
deployment target.

## Prerequisites

- Go >= 1.23
- An Azure subscription
- Azure credentials available via one of:
  - `az login` (uses `DefaultAzureCredential` in the test)
  - Service Principal env vars: `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`
  - OIDC federation (in CI, via GitHub Actions): `ARM_CLIENT_ID`, `ARM_TENANT_ID`, `ARM_USE_OIDC=true`
- `ARM_SUBSCRIPTION_ID` environment variable set

## Running locally

```bash
export ARM_SUBSCRIPTION_ID="<your-subscription-id>"
az login

cd test
go mod download
go test -v -timeout 45m
```

Expected duration: 10 to 15 minutes (create + assert + destroy).
The test creates the resources listed in `examples/complete/`, runs
assertions, then destroys everything.

### Running specific tests

```bash
go test -v -timeout 45m -run TestKeyVaultPrivateComplete
```

### Cost of a single run

~0.05 EUR — the deployed resources exist only for the ~10 minutes of the
test run. The Key Vault name goes into soft-delete for 90 days after
destroy (per ADR-003, purge protection is enabled) but incurs no cost
in that state.

Test names are randomized (via `random.UniqueId()`) so consecutive runs
do not collide on the reserved vault name.

## CI execution

This suite runs automatically in the GitHub Actions `terratest.yml`
workflow on:

- Every push to `main`
- Every pull request labeled `run-tests`
- Manual workflow dispatch

Azure authentication in CI uses OIDC federation — no client secrets
are stored in GitHub. Set `ARM_USE_OIDC=true` along with `ARM_CLIENT_ID`,
`ARM_TENANT_ID`, and `ARM_SUBSCRIPTION_ID`. See `docs/OIDC-SETUP.md` for
the setup guide.

## Troubleshooting

**Vault name is not available** — the random suffix collided with a
soft-deleted vault from a previous run. Re-run the test; the new
random suffix will differ.

**InsufficientPrivileges** — the test principal needs Contributor
at subscription scope to create/destroy the resource group.

**RoleAssignmentUpdateNotPermitted** — the test principal must also
have Role Based Access Control Administrator at subscription scope
to create the role assignments inside the Key Vault module.

**Test hangs on terraform apply** — Azure sometimes throttles PE
creation. The default 45m timeout accommodates this; if it hangs
longer, cancel and re-run.

## Extending

To add new assertions, edit `keyvault_private_test.go`. Follow the
pattern:

- `assert.*` for non-critical checks (test continues on failure)
- `require.*` for prerequisites (test stops if these fail)
- `retry.DoWithRetry` for eventual-consistency reads via the Azure SDK
