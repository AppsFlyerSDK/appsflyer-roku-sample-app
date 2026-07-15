# AppsFlyer Roku Sample App AI Workflow

## Starting a feature

To start the full feature delivery workflow, use the slash command:

```
/af-ship <short description>
```

This invokes Alice, who writes a PRD, coordinates Bob and Erin if needed, and
manages Dave through tech design, implementation, and feature documentation.
Nothing else triggers the full workflow — all other requests go directly to the
relevant skill.

## Direct invocation

For everything outside of feature delivery, invoke skills directly:

| Task | Invoke |
|------|--------|
| Code question, architecture, implementation | `dave-roku-engineer` |
| Maintenance task (see list below) | `dave-roku-engineer` |
| Platform API research, version behavior | `bob-roku-researcher` |
| Payload analysis, field mapping, schema review | `erin-roku-analyst` |

## Maintenance tasks

The following do not require a PRD or Alice review — invoke Dave directly:

- Logger / debug-message tweaks and log-level changes.
- Comment cleanup and removal of dead or commented-out code (e.g. the disabled blocks in `AppsFlyerRokuSDK.brs`).
- Renames and minor refactors that do NOT change the public `AppsFlyer()` API (`init`, `start`, `stop`, `logEvent`, `setCustomerUserId`, `trackDeepLink`, `enableDebugLogs`, `setLogLevel`).
- `manifest` version and `SDK_VERSION` bumps.
- README / doc updates (auto-synced to ReadMe.io via `.github/workflows/readme_sync.yml`).
- Adding unit tests with no behavior change.

Anything that changes the public `AppsFlyer()` API, the request payload shape, or
the first-open/session/in-app endpoint selection logic is NOT maintenance — use `/af-ship`.

## Before Making Code Changes

Before writing any code that touches a component listed in `docs/issue-cases/INDEX.md`:

1. Open `docs/issue-cases/INDEX.md` and find the component in the Hot Zones Map.
2. Read each linked IC case — pay attention to the **Takeaway** rule, and load `docs/issue-cases/GUARDRAILS.md`.
3. Explicitly state which past issues are relevant and how the new code avoids repeating them.

Do this **before writing any code** — not as a post-review step.
The Hot Zones Map in `docs/issue-cases/INDEX.md` is the authoritative, always-up-to-date source. Do not duplicate it here.

## Output contract

Every `/af-ship` deliverable must include:

- Alice PRD (`docs/prds/`)
- Bob findings (if invoked)
- Erin payload impact (if invoked)
- Dave tech design (`docs/tech-designs/`)
- Dave implementation + unit tests
- Dave feature doc (`docs/features/`)
- Alice sign-off at each phase
