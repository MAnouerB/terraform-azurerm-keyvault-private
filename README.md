# terraform-azurerm-module-template

A production-grade, AI-assisted template for building reusable Terraform
modules targeting Azure.

This repository is **not a module**. It is a starter kit that encodes
InnerSource practices, HashiCorp module standards, Azure security defaults,
and AI-assisted workflows (Claude Code). Use it to bootstrap consistent,
maintainable modules with one click.

---

## What you get out of the box

- **Standard module structure** — `main.tf`, `variables.tf`, `outputs.tf`,
  `versions.tf`, `locals.tf`, `examples/`, `test/`
- **CI/CD workflows** — `terraform fmt`, `validate`, `tflint`, `tfsec`,
  `checkov`, `terraform-docs` drift check, Infracost cost estimate on PRs,
  Terratest with OIDC authentication to Azure
- **AI-assisted layer** — `CLAUDE.md`, `.claude/commands/` with 7 slash
  commands (`/tf-add-variable`, `/tf-add-resource`, `/tf-write-example`,
  `/tf-write-terratest`, `/tf-review-pr`, `/tf-update-docs`, `/tf-release`),
  and `.ai/` context (conventions, snippets, canonical examples)
- **InnerSource ready** — issue templates, PR template, CONTRIBUTING,
  CODE_OF_CONDUCT, SECURITY policy
- **Release automation** — SemVer, Keep a Changelog, GitHub Releases
  generated from CHANGELOG on tag push
- **OIDC setup guide** — no long-lived secrets stored in GitHub

## Design principles

- **Production-representative by default** — modules built from this template
  target real production usage. Defaults are secure, HA-friendly, and do not
  degrade for cost or convenience reasons.
- **Consumer-owned surroundings** — modules never manage the resource group,
  VNet, subnet, Log Analytics workspace, or DNS zone. Consumers pass IDs.
- **Provider-agnostic composition** — modules never declare
  `provider "azurerm" {}`; that is the consumer's job.
- **Machine-readable context** — every module carries `CLAUDE.md` + `.ai/`
  so that any contributor, human or AI, can respect the design without
  reading the maintainer's mind.

## How to use this template

### 1. Create a new module repository

Click **Use this template** → **Create a new repository**, or:

```bash
gh repo create MAnouerB/terraform-azurerm-<your-module-name> \
  --template MAnouerB/terraform-azurerm-module-template \
  --public
```

Clone the new repository locally.

### 2. Rename and personalize

- Rewrite `README.md` using [`README.template.md`](README.template.md)
  as the starting point
- Fill `.ai/CONTEXT.md` with the module's purpose, scope, and non-goals
- Draft ADRs in `.ai/ARCHITECTURE.md` for the design decisions specific
  to this module (RBAC-only, private endpoint mandatory, HA defaults, etc.)
- Update `CLAUDE.md` — add module-specific `Never` and `Always` rules
- Adjust `local.module_managed_tags.module_source` in `locals.tf` (or
  in the snippet you inline from `.ai/snippets/tags-merge.tf`) to point
  to your new repository
- Update `SECURITY.md` contact and the security advisory link in
  `.github/ISSUE_TEMPLATE/config.yml`

### 3. Set up Azure OIDC

Follow [`docs/OIDC-SETUP.md`](docs/OIDC-SETUP.md) once per new module.
This creates the App Registration, federated credentials, and GitHub
secrets needed for Terratest to authenticate without stored client secrets.

### 4. Build the module

Use the Claude Code slash commands rather than freestyling:

```
/tf-add-variable <name> <type> [section]
/tf-add-resource <azurerm_type> [target-file]
/tf-write-example <name>
/tf-write-terratest <example-name>
/tf-review-pr
/tf-update-docs
/tf-release <major|minor|patch>
```

Each command reads `.ai/CONVENTIONS.md`, `.ai/examples-of-good/`, and
`.ai/snippets/` before making changes, so the output follows the module's
conventions consistently.

## Repository layout

```
.
├── CLAUDE.md                    # AI assistant entry point (auto-loaded by Claude Code)
├── .claude/
│   ├── commands/                # slash commands as workflows-as-code
│   └── settings.json            # tool permissions
├── .ai/
│   ├── CONTEXT.md               # module purpose, scope, non-goals (per module)
│   ├── ARCHITECTURE.md          # ADRs (per module)
│   ├── CONVENTIONS.md           # shared code conventions
│   ├── snippets/                # reusable Terraform patterns
│   └── examples-of-good/        # canonical style references
├── .github/
│   ├── workflows/               # ci.yml, terratest.yml, release.yml
│   ├── ISSUE_TEMPLATE/          # bug report, feature request, question
│   └── PULL_REQUEST_TEMPLATE.md
├── docs/
│   └── OIDC-SETUP.md            # one-time Azure ↔ GitHub OIDC setup
├── examples/
│   ├── basic/                   # minimal viable usage (to fill per module)
│   └── complete/                # full-featured usage (to fill per module)
├── test/                        # Terratest Go files (to fill per module)
├── main.tf                      # primary resources
├── variables.tf                 # inputs, grouped by section
├── outputs.tf                   # exposed values
├── versions.tf                  # Terraform + provider constraints
├── locals.tf                    # computed names, merged tags
├── README.template.md           # starting point for the derived module's README
├── CHANGELOG.md                 # Keep a Changelog + SemVer
├── CONTRIBUTING.md              # how to contribute
├── CODE_OF_CONDUCT.md           # Contributor Covenant 2.1
├── SECURITY.md                  # vulnerability disclosure policy
├── LICENSE                      # Apache 2.0
├── .terraform-docs.yml
├── .tflint.hcl
└── .gitignore
```

## Modules built from this template

- [`terraform-azurerm-keyvault-private`](https://github.com/MAnouerB/terraform-azurerm-keyvault-private)
- [`terraform-azurerm-postgresql-flexible`](https://github.com/MAnouerB/terraform-azurerm-postgresql-flexible)
- [`terraform-azurerm-container-apps`](https://github.com/MAnouerB/terraform-azurerm-container-apps)
- [`terraform-azurerm-aks-baseline`](https://github.com/MAnouerB/terraform-azurerm-aks-baseline)

<!-- Add new modules to this list as they are published. -->

## Versioning of the template itself

This template is versioned with SemVer independently of the modules
derived from it. Breaking changes to the template structure or CI
workflows will be signaled with a major bump and documented in
`CHANGELOG.md`.

Modules already derived from an earlier version of the template do
**not** auto-update. To apply a template improvement to an existing
module, port the change manually via a PR.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

## Author

Mohamed Anouer Bahloul — Cloud & DevOps consultant, Azure specialist.
- GitHub: [@MAnouerB](https://github.com/MAnouerB)
- Malt: [malt.fr/profile/mohamedanouerbahloul](https://www.malt.fr/profile/mohamedanouerbahloul)