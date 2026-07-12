---
description: Cut a new SemVer release
argument-hint: <major|minor|patch>
---

Prepare a new release of this module. The bump type is `$1` (major, minor, or patch).

## Steps

1. Verify the working tree is clean: `git status`
2. Verify current branch is `main` and up to date with origin
3. Read the current latest tag: `git describe --tags --abbrev=0`
   (if no tag exists, this is `0.1.0`)
4. Compute the new version:
   - `patch` → bump z in `x.y.z`
   - `minor` → bump y, reset z to 0
   - `major` → bump x, reset y and z to 0
5. Read `[Unreleased]` section of `CHANGELOG.md`. Verify:
   - It is not empty
   - Bump type matches the changes:
     - `major` required if `### Removed` or breaking `### Changed` entries exist
     - `minor` required if `### Added` entries exist without breaking changes
     - `patch` only if `### Fixed` / `### Security` only
   - If mismatch, STOP and report
6. Edit `CHANGELOG.md`:
   - Rename `[Unreleased]` to `[<new-version>] - <today YYYY-MM-DD>`
   - Insert a fresh empty `[Unreleased]` section at the top with all six
     empty category headings
7. Run the review workflow (`/tf-review-pr` logic) — abort if blocking issues
8. Show me the CHANGELOG diff and confirm the version bump before proceeding
9. Once I confirm, propose the release commit + tag commands (do NOT run them):
```bash
   git add CHANGELOG.md
   git commit -m "chore(release): <new-version>"
   git tag -a v<new-version> -m "Release v<new-version>"
   git push origin main
   git push origin v<new-version>
```
10. Propose the GitHub Release creation command:
```bash
    gh release create v<new-version> \
      --title "v<new-version>" \
      --notes-from-tag
```

## Constraints

- NEVER auto-execute git push or gh release create — always require explicit confirmation
- If `[Unreleased]` is empty, refuse to release
- If the bump type is `major` while version is still `0.x.y`, remind me that
  0.x.y already allows breaking changes and suggest a minor bump instead
- Version format is `X.Y.Z` without `v` prefix in CHANGELOG headings, but
  `vX.Y.Z` for git tags (standard convention)
