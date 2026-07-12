## What this PR does

<!-- One or two sentences. What changes, why now. -->

## Type of change

<!-- Check all that apply -->

- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change (fix or feature that changes existing consumer behavior)
- [ ] Documentation only
- [ ] CI / tooling / internal
- [ ] Refactor (no user-visible change)

## Checklist

- [ ] `terraform fmt -recursive` passes
- [ ] `terraform validate` passes on the module and every modified example
- [ ] `tflint --recursive` passes
- [ ] `tfsec .` reports no new findings
- [ ] `README.md` regenerated with `terraform-docs` (no drift)
- [ ] `CHANGELOG.md` updated under `[Unreleased]` with a user-facing entry
- [ ] Terratest coverage added or updated when a behavior changes
- [ ] `.ai/CONTEXT.md` and `.ai/ARCHITECTURE.md` still accurate

## SemVer impact

- [ ] Patch (bug fix only, no interface change)
- [ ] Minor (new input, output, or resource; no breaking change)
- [ ] Major (removed input/output, renamed variable, changed default with security or cost impact)

## Related issues

<!-- Fixes #123, refs #456 -->

## Screenshots / logs

<!-- If applicable (Infracost diff, tfsec output, Terratest run) -->

## Notes for the reviewer

<!-- Anything a reviewer should look at first, or context that isn't in the diff -->