# Architecture Decision Records

> This file MUST be customized for each module. The ADRs below are
> examples in the correct format. Replace with the actual decisions
> made for the module.

Each significant design decision is recorded as an ADR. Format inspired
by Michael Nygard's original ADR proposal.

## ADR-001: Example — RBAC over Access Policies

**Date:** YYYY-MM-DD
**Status:** Accepted

### Context

Azure Key Vault supports two authorization models: legacy Access Policies
(vault-level, hard cap of 1024 entries) and RBAC via Entra ID role assignments
(subscription/resource scope, no cap, integrates with PIM and Conditional Access).

Microsoft recommends RBAC for all new deployments.

### Decision

This module uses RBAC exclusively (`enable_rbac_authorization = true`, not
exposed as a variable — hardcoded). The module does not accept `access_policy`
blocks and does not create `azurerm_key_vault_access_policy` resources.

### Consequences

- Consumers grant access via `azurerm_role_assignment` on Key Vault
  data plane roles (`Key Vault Secrets User`, `Key Vault Administrator`, etc.)
- Migration from an existing Access Policy-based Key Vault requires a
  one-time coordination outside this module
- Simpler mental model: one authorization system, aligned with the rest
  of Azure IAM

### Alternatives considered

- Making it configurable via variable → rejected: creates two code paths
  to maintain and tests to run, and Access Policies are a legacy pattern
  we do not want to encourage

---

## ADR-002: Example — Private endpoint mandatory

**Date:** YYYY-MM-DD
**Status:** Accepted

### Context

Key Vault exposes a public endpoint by default. In multi-tenant Azure
environments with data classified as sensitive, public exposure is a
security risk and a common audit finding.

### Decision

This module sets `public_network_access_enabled = false` by default and
provisions a private endpoint + Private DNS zone A record.

The variable `public_network_access_enabled` exists but defaults to `false`.
Setting it to `true` requires the consumer to also disable network ACLs,
making the escape hatch explicit.

### Consequences

- Consumers MUST provide a subnet ID for the private endpoint and a
  Private DNS Zone ID for name resolution
- The module cannot be used to provision a public-facing Key Vault
  by default — this is intentional
- Break-glass scenarios (e.g. incident response from a public IP) require
  a temporary override outside the module

### Alternatives considered

- Making the private endpoint optional → rejected: encourages the
  insecure default and clutters the variable surface
- Managing the Private DNS Zone inside the module → rejected: DNS zones
  are typically shared across many modules and belong to a hub/platform
  resource group

---

<!-- Add ADRs as decisions are made. Keep them small (one page each).
     Once accepted, do not edit — supersede with a new ADR. -->
