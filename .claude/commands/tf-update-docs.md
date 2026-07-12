---
description: Regenerate module documentation and validate CHANGELOG
---

Refresh all documentation artifacts in this repository.

## Steps

1. Run `terraform-docs markdown table --output-file README.md --output-mode inject .`
   to regenerate the section between `<!-- BEGIN_TF_DOCS -->` and
   `<!-- END_TF_DOCS -->` markers
2. For each `examples/*/` folder:
   - Run terraform-docs to update its local `README.md` inputs/outputs section
3. Verify `README.md` sections are all present and non-empty:
   - Title + one-line description
   - Features (bullet list)
   - Requirements (auto)
   - Providers (auto)
   - Modules (auto, if any)
   - Resources (auto)
   - Inputs (auto)
   - Outputs (auto)
   - Usage (minimal snippet + link to examples/basic)
   - Examples (list with links)
   - Design decisions (link to `.ai/ARCHITECTURE.md`)
   - Contributing (link to `CONTRIBUTING.md`)
   - License
4. Verify `CHANGELOG.md`:
   - `[Unreleased]` section exists at top
   - Entries are in the correct categories
   - Wording is user-facing (fix any commit-style entries)
5. Verify `.ai/CONTEXT.md` still reflects the module's actual scope
   (flag drift if new resources introduced concerns not documented)
6. Report any documentation drift or missing sections
7. Show me the diff before writing
