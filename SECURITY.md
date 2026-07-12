# Security Policy

## Reporting a vulnerability

If you discover a security vulnerability in this module, please report it
privately. Do NOT open a public GitHub issue for security matters.

### Preferred: GitHub Security Advisories

Use GitHub's private vulnerability reporting:

1. Go to the repository's **Security** tab
2. Click **Report a vulnerability**
3. Fill in the advisory form

This creates a private discussion between you and the maintainers, with
the option to request a CVE once triaged.

### Alternative: email

If you cannot use GitHub Security Advisories, send an email to:

**bahloulmohamedanouer@gmail.com**

Please include:

- A description of the vulnerability
- Steps to reproduce (Terraform snippet if applicable)
- The module version affected
- Potential impact

Encrypt sensitive details with the maintainer's public key if you have
one; otherwise plain text is acceptable — the report will be moved to
a private channel on receipt.

## What to expect

- Acknowledgement within **72 hours** of receipt
- An initial assessment within **7 days**
- A fix and coordinated disclosure timeline agreed with you

Please give us reasonable time to investigate and patch before any public
disclosure. We follow a 90-day disclosure window by default; longer is
possible if the fix requires coordination with Azure or upstream providers.

## Scope

In scope:

- Vulnerabilities in the Terraform code of this module that lead to
  insecure Azure configurations (e.g. a default that exposes a resource
  publicly when the consumer did not opt in)
- Vulnerabilities in the CI workflows that could leak secrets or grant
  unauthorized access

Out of scope:

- Vulnerabilities in Terraform itself, the azurerm provider, or Azure
  services (report those upstream)
- Vulnerabilities in a consumer's usage of the module that stem from
  the consumer's own configuration
- Findings from generic scanners that do not represent a real risk in
  context (please investigate before reporting)

## Credit

Reporters who wish to be credited will be listed in the release notes of
the patched version. Anonymous reports are equally welcome.

## Supported versions

While the module is at `0.x.y`, only the latest minor version is
supported for security fixes. Once `1.0.0` is released, we will document
the supported version window here.