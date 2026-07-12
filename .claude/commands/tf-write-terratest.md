---
description: Add a Terratest case for an example
argument-hint: <example-name-from-examples-folder>
---

Add or update a Terratest case that runs `examples/$1/` end-to-end on Azure.

## Steps

1. Read the target `examples/$1/` to understand what it deploys
2. In `test/`, create or edit `${1}_test.go` (snake_case)
3. Use the Terratest patterns:
   - `terraform.Options` pointing to `../examples/$1`
   - `defer terraform.Destroy(t, terraformOptions)` FIRST — before apply
   - `terraform.InitAndApply(t, terraformOptions)`
   - Assertions via `testify/assert` on outputs and Azure API state
4. Assertions to include (adapt per module):
   - resource exists (via azurerm SDK or `terraform.Output` + Azure CLI)
   - security posture: `public_network_access_enabled` is false
   - diagnostic settings are configured
   - tags include the module-managed metadata
5. Set `t.Parallel()` at the top of the test function to allow concurrent runs
6. Use randomized suffixes (`random.UniqueId()`) for resource names to allow
   parallel test runs without collision
7. If the test needs credentials, document env vars in `test/README.md`:
   `ARM_CLIENT_ID`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`,
   `ARM_USE_OIDC=true` (for CI) or `ARM_CLIENT_SECRET` (local only, discouraged)
8. Update `test/go.mod` if new dependencies are needed
   (`go get github.com/gruntwork-io/terratest/modules/...`)
9. Show me the file before writing

## Constraints

- Timeout budget: 60 minutes max per test (AKS + PostgreSQL HA can take 20+ min)
- ALL resources created MUST be destroyed by `defer` — no orphans, ever
- Use production-representative SKUs and configurations. The purpose of these
  tests is to validate the module against realistic prod scenarios, not to
  minimize cost:
  - PostgreSQL Flexible Server: GP tier minimum, zone-redundant HA when
    the module supports it
  - AKS: at least 2 nodes, Standard tier, private cluster
  - Key Vault: Standard SKU is fine (Premium only when HSM is required)
  - Container Apps: Consumption or Dedicated depending on what the example
    demonstrates
- If the tested example provisions premium resources, add a comment at the
  top of the test function stating the expected run duration and rough
  cost order of magnitude (informational, not a limit)
- Prefer `t.Parallel()` for tests targeting independent examples so total
  wall-clock time stays reasonable
