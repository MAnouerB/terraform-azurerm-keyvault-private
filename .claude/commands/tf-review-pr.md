---
description: Self-review the current changes before pushing
argument-hint: (no arguments — refreshes README, examples READMEs, and CHANGELOG)
---

Perform a rigorous self-review of the current uncommitted changes as if
you were a reviewer on the SKY Cloud/Builder team.

## Steps

1. Run `git status` and `git diff` to see what changed
2. For each modified `.tf` file, check:
   - Formatting: run `terraform fmt -check -recursive` and report violations
   - Validation: run `terraform validate` in the module root and in each
     modified example
   - Linting: run `tflint --recursive` and report findings
   - Security: run `tfsec .` and report findings
3. For each new variable:
   - Description present, imperative, ends with a period?
   - Type explicit?
   - Validation block present for enums / ranges / CIDRs?
   - Default is the sensible-and-secure option?
   - `sensitive = true` if it carries a secret?
4. For each new resource:
   - Diagnostic settings wired if supported?
   - `for_each` over `count` where applicable?
   - No hardcoded values (SKU, region, tags)?
   - Follows naming convention from `.ai/CONVENTIONS.md`?
5. For each new output:
   - Named consistently with the resource it exposes?
   - `sensitive = true` if it carries a secret?
6. `README.md`:
   - terraform-docs section is up to date (compare with a fresh run)
   - New examples listed in the Examples section
7. `CHANGELOG.md`:
   - Entry under `[Unreleased]` in the right category
     (Added / Changed / Deprecated / Removed / Fixed / Security)
   - Wording is user-facing (not commit-style)
8. Terratest coverage:
   - New behavior has a corresponding assertion
   - No orphaned resources at end of test
9. Breaking change check: does this change require a major SemVer bump?
   Flag it explicitly if yes

## Output

Produce a review report with:
- ✅ what's good
- ⚠️  what should be improved (non-blocking)
- ❌ what MUST be fixed before push (blocking)
- 🚨 breaking change flag if applicable

Be blunt. This is a self-review, not a pat on the back.
