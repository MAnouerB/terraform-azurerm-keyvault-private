# Module Context

> This file MUST be customized for each module derived from this template.
> Delete this quote block once done.

## Purpose

<One paragraph: what this module provisions and why it exists.
Example: "Provisions an Azure Key Vault with private endpoint, RBAC-only
authorization, and diagnostic settings. Designed as a drop-in secrets
store for platform and application teams that need Entra ID-based access
and no public network exposure.">

## Scope

This module manages:

- <resource 1>
- <resource 2>
- <resource 3>
- <supporting resources: private endpoint, private DNS zone A record,
  diagnostic settings, role assignments if module-managed>

## Non-goals

This module does NOT manage:

- The resource group (passed in via `resource_group_name`)
- The VNet or subnet used for the private endpoint (passed in via IDs)
- The Log Analytics workspace used for diagnostic settings (passed in via ID)
- The Private DNS Zone itself (passed in via ID) — only the A record inside it
- <any other explicit non-goal>

Rationale: this module is designed to be composed with existing platform
resources. Consumers own the surrounding infrastructure.

## Consumers

Intended consumers:

- Platform teams provisioning secrets stores for multiple application teams
- Application teams via a self-service pattern (module called from their
  own root modules or via a higher-level composition)

Consumers are expected to:

- Provide a pre-existing resource group, VNet, subnet, and Log Analytics workspace
- Grant themselves the appropriate Entra ID roles on the created Key Vault
- Pin to a minor version (`~> 0.2`) while the module is at `0.x.y`

## Dependencies

Required before calling this module:

- A resource group in the target subscription
- A VNet with a subnet dedicated to (or shared with) private endpoints
- A Log Analytics workspace for diagnostic settings
- A Private DNS Zone `privatelink.<service>.<region>.<domain>` linked to the VNet

## Security posture

- Public network access: disabled by default
- Authorization: RBAC only (Access Policies are not supported by this module)
- Network access: private endpoint only, no service endpoints, no firewall rules
  for public IPs
- Diagnostic settings: enabled by default when a workspace ID is provided
- Soft delete and purge protection: enabled by default (cannot be disabled
  once enabled — this is intentional)

## Versioning policy

- Semantic Versioning
- While at `0.x.y`, any release may include breaking changes
- Consumers should pin to a minor version: `version = "~> 0.2"`
- Once `1.0.0` is released, breaking changes only on major bumps

## Glossary

- **PE**: Private Endpoint — Azure resource that provides a private IP for a PaaS service inside a VNet
- **Private DNS Zone**: Azure DNS zone linked to a VNet, resolving PaaS service FQDNs to their private IPs
- **RBAC**: Role-Based Access Control via Entra ID role assignments
- **Diagnostic Settings**: Azure feature that streams platform logs and metrics to a destination (Log Analytics, Storage, Event Hub)
