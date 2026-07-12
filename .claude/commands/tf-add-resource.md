---
description: Add a new Azure resource to this module
argument-hint: <azurerm_resource_type> [target-file:main|network|security|observability]
---

Add a new Azure resource of type `$1` to this module.

## Steps

1. Read `.ai/CONTEXT.md` to confirm this resource is in scope (not a non-goal)
2. Read `.ai/ARCHITECTURE.md` for existing ADRs that may constrain this
3. Read `.ai/CONVENTIONS.md` for resource naming and file placement rules
4. Decide the target file based on concern:
   - `main.tf` → primary resource of this module
   - `network.tf` → networking (VNet, subnet, PE, DNS, NSG)
   - `security.tf` → RBAC, identities, policies, encryption
   - `observability.tf` → diagnostic settings, alerts
5. Copy the closest matching pattern from `.ai/snippets/` if one exists:
   - Private endpoint + Private DNS zone → `.ai/snippets/private-endpoint.tf`
   - Diagnostic settings → `.ai/snippets/diagnostic-settings.tf`
   - Tags merge → `.ai/snippets/tags-merge.tf`
6. For each attribute, prefer the more secure default. Never set:
   - `public_network_access_enabled = true` without an explicit variable and
     a `# tfsec:ignore` justified comment
   - `local_authentication_enabled = true` when Entra ID auth is available
   - hardcoded IPs, CIDRs, or region strings
7. Wire diagnostic settings if the resource supports them
8. Expose relevant IDs and names in `outputs.tf`
9. Add the resource to `examples/complete/` if user-facing configuration
   is involved
10. Update Terratest assertions in `test/` for the new resource
11. Add a `CHANGELOG.md` entry under `[Unreleased] / ### Added`
12. Regenerate terraform-docs section in `README.md`
13. Show me the diff before writing

## Constraints

- Resource must respect `for_each` over `count` when multiple instances possible
- Timeouts blocks required for long-provisioning resources (KV, PostgreSQL, AKS)
- If a data source is needed, prefer passing an ID via a variable over
  looking up by name (avoids ambient authority)
