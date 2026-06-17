# Security Policy

The TEC Federated Platform handles Pi Network identities, KYC data, wallets, and payments.
Security is governed constitutionally — see `knowledge-base/C-15` (Security Rules),
`knowledge-base/C-90` (Security & Trust Model / STRIDE), `knowledge-base/C-17`
(Data Privacy & Compliance), and `knowledge-base/C-19` (Fraud, Abuse & AML).

> **Note:** This repository is the **knowledge base** (documentation + CI validators).
> Application/runtime code lives in the platform service and app repositories. Report
> vulnerabilities affecting any TEC component here unless the affected repo states otherwise.

## Reporting a Vulnerability

- **Do NOT** open a public GitHub issue for security vulnerabilities.
- Report privately via **GitHub Security Advisories** ("Report a vulnerability" under the
  repository's *Security* tab), or contact the maintainer directly (see repository owner).
- Please include: affected component, impact, reproduction steps, and any logs/PoC.

## What to Expect

- Acknowledgement of your report.
- An assessment of severity and affected scope.
- Coordinated remediation; we ask you not to disclose publicly until a fix is available.

## Scope & Severity

Severity follows the incident model in `knowledge-base/C-73` (Incident Response Runbook):

- **P0** — active exploitation, fund loss/at-risk, secret leak, auth bypass.
- **P1** — high-impact, no active exploitation.
- **P2** — limited-impact or hardening issues.

## Handling of Sensitive Data

Personal and financial data is classified and protected per `knowledge-base/C-17`.
Please avoid including real user data (C3/C4) in reports — use redacted/synthetic examples.

## Out of Scope

- Findings in third-party services (Pi Network, Railway, Vercel, Supabase) — report to those vendors.
- Documentation typos (open a normal issue/PR instead).
