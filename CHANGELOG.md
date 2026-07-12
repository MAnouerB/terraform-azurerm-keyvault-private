# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

While this module is at `0.x.y`, any release may include breaking changes.
Once `1.0.0` is released, breaking changes will only occur on major version bumps.

## [Unreleased]

### Added

- New input variable `log_analytics_workspace_id` to specify the Log Analytics workspace that receives diagnostic logs and metrics.

### Changed

### Deprecated

### Removed

### Fixed

### Security

<!--
## [0.1.0] - YYYY-MM-DD

### Added
- Initial release
-->
##  [0.1.0] - 2026-07-12

### Added 

- Initial template release
- Standard Terraform module structure (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `locals.tf`)
- AI-assisted layer: `CLAUDE.md`, `.claude/settings.json`, and 7 slash commands
  (`/tf-add-variable`, `/tf-add-resource`, `/tf-write-example`,
  `/tf-write-terratest`, `/tf-review-pr`, `/tf-update-docs`, `/tf-release`)
- `.ai/` context: `CONTEXT.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`,
  reusable snippets (tags merge, private endpoint, diagnostic settings,
  variable validation), canonical style references (good-variable,
  good-resource, good-output)
- GitHub Actions CI workflow (`ci.yml`): terraform fmt, validate, tflint,
  tfsec, checkov, terraform-docs drift check, Infracost cost estimate
- GitHub Actions Terratest workflow (`terratest.yml`) with OIDC to Azure,
  label-gated on PRs (`run-tests`), automatic on push to main
- GitHub Actions Release workflow (`release.yml`) that publishes a
  GitHub Release from CHANGELOG on tag push
- InnerSource files: PR template, three issue templates (bug, feature,
  question), `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- OIDC setup guide (`docs/OIDC-SETUP.md`) for one-time Azure ↔ GitHub
  federated credential configuration
- Repository meta-README (`README.md`) and module README template
  (`README.template.md`)
- Configuration files: `.gitignore`, `.tflint.hcl`, `.terraform-docs.yml`
- Apache 2.0 license
