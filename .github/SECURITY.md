# Security Policy

## Supported Versions

Tendril Tasks is in active `0.x` development. Security fixes are only released
for the latest minor version. Please upgrade to the latest release before
reporting an issue.

| Version | Supported          |
| ------- | ------------------ |
| 0.6.x   | :white_check_mark: |
| < 0.6   | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues,
discussions, or pull requests.**

Report vulnerabilities privately using one of these channels:

1. **GitHub (preferred):** [Report a vulnerability](https://github.com/david-uhlig/tendril-tasks/security/advisories/new)
   through GitHub's private vulnerability reporting.
2. **Email:** david.uhlig[at]gmail.com with the subject line
   `[SECURITY] Tendril Tasks`.

Please include as much of the following as you can:

- The affected version or commit
- The type of issue (e.g. XSS, authorization bypass, CSRF, SQL injection)
- The affected route, controller, or file
- Step-by-step instructions to reproduce the issue
- A proof of concept, if available
- The impact, including how an attacker might exploit the issue
- Relevant configuration, e.g. Rocket.Chat version or deployment setup

## What to Expect

Tendril Tasks is maintained by a single person in their spare time. I will do
my best to:

- Acknowledge your report within **7 days**
- Confirm the issue and share an initial assessment within **14 days**
- Keep you informed about progress towards a fix

Once a fix is released, it is listed under **Security** in the
[changelog](../CHANGELOG.md), and a GitHub security advisory is published where
appropriate. You will be credited for the discovery unless you prefer to remain
anonymous.

Please give me a reasonable amount of time to release a fix before disclosing
the issue publicly. I aim to resolve confirmed vulnerabilities within 90 days.

## Scope

In scope:

- The Tendril Tasks application code in this repository
- The default configuration and deployment setup shipped with it (Dockerfile,
  Kamal configuration)

Out of scope:

- Vulnerabilities in Rocket.Chat or other third-party services; please report
  them to the respective project
- Vulnerabilities in dependencies that are not exploitable through Tendril
  Tasks; please report them upstream
- Issues that require a compromised server, administrator account, or physical
  access
- Misconfigured self-hosted instances
- Denial-of-service attacks, social engineering, and automated scanner output
  without a demonstrated impact

## Safe Harbor

Research conducted in good faith and in line with this policy is welcome. Please
only test against instances you own or are authorized to test, avoid accessing
or modifying other users' data, and avoid degrading the service for others.
