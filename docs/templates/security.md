# Security Policy

## Supported Versions

The following versions of Project receive security updates:

| Version | Supported |
|---|---|
| Latest release (current) | Yes |
| Previous minor release | Yes (critical and high severity only) |
| Older releases | No |

We recommend always running the latest version.

## Reporting a Vulnerability

**Email: security@myproject.vn**

**Do NOT open a public GitHub issue for security vulnerabilities.** Public disclosure before a fix is available puts all Project users at risk.

### What to Include

Please provide as much of the following as possible:

- Description of the vulnerability.
- Steps to reproduce the issue.
- Affected component(s) and version(s).
- Potential impact (data exposure, privilege escalation, denial of service, etc.).
- Suggested fix or mitigation (if any).
- Your contact information for follow-up.

### What to Expect

| Step | Timeline |
|---|---|
| Acknowledgment of your report | Within 24 hours |
| Initial assessment and severity classification | Within 48 hours |
| Regular status updates | At least weekly |
| P0 (critical) fix deployed | Within 48 hours of confirmation |
| P1 (high) fix deployed | Within 1 week |
| P2 (medium) fix deployed | Within 2 weeks |
| Notification to reporter when fix is released | Same day as deployment |

We will coordinate with you on disclosure timing. We aim to fix vulnerabilities before any public disclosure.

## Safe Harbor

Project supports responsible security research. We will not pursue legal action against individuals who:

- Act in good faith to discover and report vulnerabilities.
- Report vulnerabilities privately through the process described above.
- Do not access, modify, or delete data belonging to other users or tenants.
- Do not disrupt service availability (no denial-of-service testing against production).
- Do not exploit a vulnerability beyond what is necessary to demonstrate it.
- Allow reasonable time for the issue to be resolved before any public disclosure.

## Scope

This security policy applies to all Project repositories:

- myproject-core
- myproject-frontend
- myproject-crypto
- myproject-compliance
- myproject-ingestion
- myproject-ai
- myproject-infra
- myproject-docs

## Security Best Practices for Contributors

If you are contributing to Project, please follow the [security guidelines](../guidelines/security-guidelines.md) to ensure your code meets our security standards.
