# Architecture Decision Records — terraform-azurerm-keyvault-private

Each significant design decision is recorded as an ADR.

---

## ADR-001: RBAC over Access Policies

**Date:** 2026-07-12
**Status:** Accepted

### Context

Azure Key Vault supports two authorization models:

- **Access Policies** (legacy): vault-scoped, hard cap of ~1024 entries,
  no PIM / Conditional Access integration
- **RBAC** via Entra ID role assignments: subscription/resource scope,
  no cap, integrates with PIM, Conditional Access, ABAC conditions

Microsoft recommends RBAC for all new Key Vault deployments.

### Decision

This module uses RBAC exclusively. `enable_rbac_authorization = true`
is hardcoded — not exposed as a variable. The module does not accept
`access_policy` blocks and does not create `azurerm_key_vault_access_policy`
resources.

Consumers grant access via the `role_assignments` input variable (map of
role assignments) or via their own `azurerm_role_assignment` resources
outside the module.

### Consequences

- Migration from an existing Access Policy-based Key Vault requires
  coordination outside this module
- Simpler mental model: one authorization system, aligned with the rest
  of Azure IAM
- No dual-mode code paths to maintain

### Alternatives considered

- Making it configurable via variable → rejected: two code paths to
  test, and Access Policies are a legacy pattern we should not encourage

---

## ADR-002: Private endpoint mandatory for production usage

**Date:** 2026-07-12
**Status:** Accepted

### Context

Key Vault exposes a public endpoint by default. In multi-tenant Azure
environments with sensitive data, public exposure is a common audit
finding and increases the attack surface.

### Decision

- `public_network_access_enabled` defaults to `false`
- The module always provisions a Private Endpoint and DNS A record when
  invoked with `subnet_id_private_endpoint` and `private_dns_zone_id`
- The variable `public_network_access_enabled` exists to allow the
  `examples/basic` pattern (dev/test scenarios) but its default is `false`

### Consequences

- Consumers MUST provide a subnet ID for the private endpoint and a
  Private DNS Zone ID for name resolution when using the module in its
  default posture
- `examples/basic` documents the public-network pattern explicitly and
  warns against production use
- `examples/complete` demonstrates the private-only production pattern

### Alternatives considered

- Making the private endpoint optional → rejected as the default;
  accepted for `examples/basic` only with an explicit warning
- Managing the Private DNS Zone inside the module → rejected: DNS zones
  are typically shared across many modules and belong to a hub/platform
  resource group

---

## ADR-003: Purge protection is irreversible and always on

**Date:** 2026-07-12
**Status:** Accepted

### Context

Azure Key Vault supports `purge_protection_enabled`. Once enabled on a
vault, it CANNOT be disabled — the property is immutable on that vault
instance. Disabling requires vault deletion + waiting out the soft-delete
retention window.

The security benefit is significant: purge protection prevents an
attacker (or a mistake) from permanently destroying keys and secrets
during the soft-delete window.

### Decision

`purge_protection_enabled` is hardcoded to `true` in the module. It is
NOT exposed as a variable.

### Consequences

- Consumers cannot opt out of purge protection through this module
- A vault created by this module cannot be permanently deleted before
  the soft-delete retention window expires — this is the intended
  security property
- Test scenarios (Terratest) must account for this: destroyed vaults
  will remain soft-deleted; test resource names should be randomized to
  avoid name collisions across runs

### Alternatives considered

- Making it a variable with `default = true` → rejected: exposing a
  variable signals "you can turn this off", which contradicts the
  security intent
- Setting it to `false` for `examples/basic` → rejected: soft-delete
  retention days can be minimized (7 days) for dev/test cleanup without
  weakening purge protection

---

## ADR-004: Tenant ID as an explicit variable

**Date:** 2026-07-12
**Status:** Accepted

### Context

Key Vault requires a `tenant_id` at creation. Many modules default to
`data.azurerm_client_config.current.tenant_id`, which uses the tenant of
the identity currently running Terraform.

This is convenient but couples the module to ambient authority. In
multi-tenant scenarios (e.g. deploying resources into a partner tenant
via delegated resource management, or cross-tenant automation),
`data.azurerm_client_config` returns the wrong tenant.

### Decision

The module requires `tenant_id` as an explicit variable. It does not use
`data.azurerm_client_config.current.tenant_id` internally.

Consumers who want the "current tenant" behavior explicitly opt in from
their root module:

```hcl
data "azurerm_client_config" "current" {}

module "kv" {
  source    = "..."
  tenant_id = data.azurerm_client_config.current.tenant_id
  # ...
}
```

### Consequences

- Extra one-line requirement for consumers, offset by portability
- Cross-tenant scenarios work out of the box
- Explicit is better than implicit — the tenant boundary is a security
  boundary, and the module should not resolve it silently

### Alternatives considered

- Default to `data.azurerm_client_config` → rejected: ambient authority
  is a code smell in modules intended for multi-team consumption

---

## ADR-005: Vault is the container, not the content

**Date:** 2026-07-12
**Status:** Accepted

### Context

Modules that manage both the vault and its contents (secrets, keys,
certificates) tend to grow into monoliths and force consumers into a
one-size-fits-all secret lifecycle.

### Decision

This module provisions the vault and nothing inside it. It does NOT
create:

- `azurerm_key_vault_secret`
- `azurerm_key_vault_key`
- `azurerm_key_vault_certificate`
- `azurerm_key_vault_managed_hardware_security_module_*`

Consumers manage the contents in their own root modules or via
dedicated modules.

### Consequences

- Small, focused module surface
- Consumers choose their own secret lifecycle strategy (imported, rotated
  via Functions, generated by another module, etc.)
- Contents survive vault redeployments (consumers can `terraform import`
  or reference secrets from a separate state)

### Alternatives considered

- Providing an optional `secrets` map input → rejected for `v0.1.0`;
  may be reconsidered as a separate companion module

---

## ADR-006: CMK deferred to v0.2.0

**Date:** 2026-07-12
**Status:** Accepted (deferred scope)

### Context

Customer-Managed Key (CMK) encryption of the vault itself is a
production-hardening feature (encryption of vault storage with a key
controlled by the customer, not Microsoft). It requires:

- An identity (system-assigned or user-assigned) on the vault with
  `Key Vault Crypto Service Encryption User` on the CMK
- A `azurerm_key_vault_key` in a separate vault
- `key_vault_key_id` and `identity` blocks on the target vault

### Decision

CMK is out of scope for `v0.1.0`. The module will add CMK support in
`v0.2.0` behind an opt-in variable.

The system-assigned managed identity on the vault (an `identity` block on
`azurerm_key_vault`, and the `system_assigned_identity_principal_id` output
that exposes its `principal_id`) is a prerequisite for CMK and is likewise
deferred to `v0.2.0`. `v0.1.0` provisions no identity on the vault.

### Consequences

- `v0.1.0` uses Microsoft-managed keys for vault storage encryption
  (default Azure behavior)
- Consumers requiring CMK should wait for `v0.2.0` or wrap the module
  with their own configuration
- CHANGELOG will announce CMK as a minor bump (additive, non-breaking)

### Alternatives considered

- Bundling CMK in `v0.1.0` → rejected: increases scope, delays first
  release, and adds a chicken-and-egg dependency on another Key Vault