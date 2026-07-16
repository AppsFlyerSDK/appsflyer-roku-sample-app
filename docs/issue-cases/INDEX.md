---
name: issue-cases
description: >-
  Historical engineering issue bank — real bugs, crashes, and lost-attribution
  defects mined from git history and cross-checked against Jira. Includes a hot
  zones map and two-axis (Component × Bug Class) classification. Read before
  modifying historically fragile components.
type: reference
---

# Issue Case Bank — AppsFlyer Roku Sample App

Real defects in the AppsFlyer Roku SDK integration and sample channel — the bugs
that shaped the current guardrails.

## Case Index

| # | Name | Component | Bug Class | Severity | Commit |
|---|------|-----------|-----------|----------|--------|
| [IC-001](IC-001-logger-reads-nonexistent-log-file.md) | Logger reads a non-existent log file | `AppsFlyerRokuSDK.brs` (Logger) | null-safety | LOW | `9274247` |
| [IC-002](IC-002-deprecated-getversion-os-version.md) | Deprecated `GetVersion()` yields `999.9999999` | `AppsFlyerRokuSDK.brs` (common fields) | api-contract | MEDIUM | — |
| [IC-003](IC-003-counter-incremented-before-delivery.md) | Launch counter incremented before delivery → `first_open` lost | `AppsFlyerRokuSDK.brs` (af_trackAppLaunch) | state-management | HIGH | — |

---

**How to use this file:**
- Check the Hot Zones Map first — it shows which components carry the most historical risk.
- When modifying a component, look up its cases by component name.
- When writing a new launch-state / null-handling / device-API pattern, look up cases by bug class.
- Apply each case's Takeaway — it distills the anti-pattern into an actionable rule (see also [`GUARDRAILS.md`](GUARDRAILS.md)).

---

## Hot Zones Map

| Component | Known Issues | Dominant Bug Classes | Cases |
|-----------|--------------|----------------------|-------|
| `AppsFlyerRokuSDK.brs` | ███ 3 | null-safety, api-contract, state-management | IC-001, IC-002, IC-003 |

> **Scale note:** this is a young repository (27 commits since 2023, mostly docs),
> so "Known Issues" is ranked by distinct issue cases per component rather than by
> the per-5-fix-commit bar used for mature services. `AppsFlyerRokuSDK.brs` exists
> as byte-identical copies under `appsflyer-integration-files/` and
> `appsflyer-sample-app/source/source/` — a fix in one must be applied to both.
> These files have had only cosmetic changes and carry no cases yet:
> `AppsFlyerHTTPTask.brs`, `Main.brs`, `AppsFlyerScene.brs`.

---

## Bug Class Reference

| Class | What it covers |
|-------|---------------|
| `concurrency` | Race conditions, thread-unsafe shared state, main-thread violations |
| `null-safety` | `Invalid`/nil dereferences, missing guards at API boundaries |
| `type-system` | Wrong type assumptions, string-vs-number confusion, sentinel values |
| `logic-error` | Wrong conditions, dead paths, parameter confusion, silent wrong output |
| `memory-safety` | Use-after-free, retain cycles, buffer overread (rare in BrightScript) |
| `serialization` | Encoding/decoding errors, payload/format mismatch, signing over wrong bytes |
| `state-management` | Counter/flag lifecycle, persisted-state ordering, optimistic mutation |
| `api-contract` | Violated preconditions, deprecated platform APIs, network resilience gaps |
| `build-pipeline` | Packaging/sideload issues, manifest errors, tree drift |
| `security-gap` | Detection disabled, validation bypassed, insecure default config |

---

## Cases by Bug Class

- **null-safety:** IC-001
- **api-contract:** IC-002
- **state-management:** IC-003
