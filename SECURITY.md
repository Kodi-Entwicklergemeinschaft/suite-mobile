# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.x   | ✅        |

## Reporting a Vulnerability

Please **do not** report security vulnerabilities through public issues.

Instead, email **info@heidi-app.de** with:

- A description of the vulnerability and its potential impact
- Steps to reproduce (proof of concept if possible)
- Affected template(s) or package(s) and version/commit

You will receive an initial response within **7 days**. We will keep you
informed about the progress of the fix and coordinate disclosure with you.

## Scope

This policy covers the code in this repository (app templates
`apps/template_a`–`template_c` and the shared packages under `packages/`).
Backend services and municipality-specific deployments are out of scope here —
report those to the same address and they will be routed internally.

## Hardening Notes

- No secrets are hardcoded; all instance configuration is injected via
  `assets/env/.env` (see `.env.example`).
- Release builds for Template C ship with ProGuard enabled.
