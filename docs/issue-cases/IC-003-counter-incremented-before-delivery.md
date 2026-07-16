---
commit: —
year: 2026
feature_ref: [F-005, F-009]
---

## IC-003 — Launch counter incremented before delivery is confirmed → `first_open` lost, later events go organic

**Component:** `AppsFlyerRokuSDK.brs` › `AppsFlyerCore().af_trackAppLaunch` (with `AppsFlyerHTTPTask.brs`)
**Bug class:** state-management
**Severity:** HIGH
**Ticket:** DELIVERY-116076 (P1 Bug)
**Commit:** —
**Branch:** —
**Date:** 2026-03-25

### What Happened
The launch counter (`AppsFlyerCounter`) is incremented and persisted at launch time — **before** the `first_open`/conversion request is confirmed ([AppsFlyerRokuSDK.brs#L108](https://github.com/AppsFlyerSDK/appsflyer-roku-sample-app/blob/main/appsflyer-integration-files/source/AppsFlyerRokuSDK.brs#L108)). Endpoint selection then reads that counter: `0/1/2 → first_open`, `≥3 → session`.

### Observable Symptom
For a Tier-1 client (DIRECTV), when the first launches happened with no/slow connectivity, `first_open` never landed; on later launches the counter had already advanced past 2, so the SDK sent `session` instead. The install/conversion was permanently missing, and per RTA every subsequent event was attributed as **organic**.

### Root Cause
Attribution state advanced on a side effect (the launch happening) rather than on the confirmed success of the conversions API. `isFirstCall` compounded it by reading an unset `common.counter` (always `"false"`).

### Fix Applied
Not yet committed. Recommended: increment/persist the counter only after a confirmed `200/202`, and only for the real launch request (the one that carries `conReqUrl`); drive endpoint choice from a persisted "first-open sent" flag so `first_open` keeps being retried across launches until the server accepts it.

### Takeaway
Never advance persisted attribution state (counters, "first_open sent") on a fire-and-forget send. Mutate it only after the server confirms delivery (200/202) — otherwise a flaky network silently and permanently loses the install, and everything after it becomes organic.
