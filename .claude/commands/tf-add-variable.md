---
description: Add a new input variable following module conventions
argument-hint: <variable-name> <type> [section:general|configuration|network|security|observability]
---

Add a new input variable named `$1` (type `$2` if provided, otherwise
infer from context) to this Terraform module.

## Steps

1. Read `.ai/CONVENTIONS.md` for variable format rules
2. Read `.ai/examples-of-good/good-variable.tf` as the style reference
3. Add the variable to `variables.tf` in the correct section:
   - General → name, location, resource_group_name, tags
   - Configuration → module behavior toggles
   - Network → VNet, subnet, private endpoint, DNS
   - Security → RBAC, identities, access control
   - Observability → diagnostic settings, log analytics
4. Include:
   - `description` (imperative, ends with a period, mentions default behavior)
   - explicit `type`
   - `default` if a sensible-and-secure one exists
   - `validation` block for string enums, ranges, or CIDR blocks
   - `sensitive = true` if the value is a secret
   - `nullable = false` when null is not meaningful
5. If the variable drives resource behavior, wire it in the relevant `.tf`
   file (main / network / security / observability)
6. Regenerate the terraform-docs section in `README.md`:
   `terraform-docs markdown table --output-file README.md --output-mode inject .`
7. Add a `CHANGELOG.md` entry under `[Unreleased] / ### Added`:
    - New input `$1` to configure [purpose]
8. If the variable is user-facing, update `examples/complete/` to demonstrate it
9. Show me the full diff before writing anything to disk

## Constraints

- Defaults MUST prefer the more secure option
- No breaking change: existing consumers must not need to update their code
- Match description style: imperative, ends with a period
- Boolean flags with security implications MUST be documented in the description
