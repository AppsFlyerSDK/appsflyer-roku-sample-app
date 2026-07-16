---
name: guardrails
description: >-
  Actionable engineering rules distilled from real AppsFlyer Roku SDK bugs
  (see IC cases). Read before changing launch, logging, or payload-field code.
type: reference
---

# Guardrails — AppsFlyer Roku Sample App

Rules distilled from the historical issue cases in this bank. Each rule cites the
case(s) it comes from. When a rule and a deadline conflict, the rule wins.

## Tech Design Checklist

Work through this before writing a tech design that touches launch/session or
payload code:

- [ ] Backend/consumer schema sign-off for any new or renamed payload key (e.g. `device_os_version`, counters, `isFirstCall`).
- [ ] Cross-tree alignment check — every SDK change is mirrored in **both** `appsflyer-integration-files/` and `appsflyer-sample-app/source/source/` (they must not drift).
- [ ] All launch paths covered — `trackAppLaunch` and `trackDeepLink`, first install vs. reinstall, online vs. offline first launch.
- [ ] Persisted-state transitions (counters, "first-open sent" flags) happen only after a confirmed server response.

---

## Rules

### GR-01 — Validate every platform/device API return before using it
Roku APIs can "succeed" and still hand back an unusable value. Validate the result
of `roDeviceInfo.GetVersion()`/`GetOSVersion()`, registry reads, and JSON parses
against a sane range before consuming them, and prefer the currently-supported API
over a deprecated one.
**Never:** assume a device API returned a valid, in-range value (e.g. accept a `999.9999999` OS version).
Source: [IC-002](IC-002-deprecated-getversion-os-version.md)

### GR-02 — Guard `tmp:/` file reads with `MatchFiles`
The `tmp:/` filesystem is empty on first launch and after every reboot. Confirm a
file exists before `ReadAsciiFile`, and treat a missing file as empty content.
**Never:** `ReadAsciiFile("tmp:/...")` without a `MatchFiles` existence check.
Source: [IC-001](IC-001-logger-reads-nonexistent-log-file.md)

### GR-03 — Advance persisted state only after a confirmed success
Increment/persist counters and set "sent" flags only after a `200/202` for the
request they describe — never optimistically at send time.
**Never:** mutate the launch counter on a fire-and-forget POST.
Source: [IC-003](IC-003-counter-incremented-before-delivery.md)

### GR-04 — Drive endpoint selection from confirmed flags, not premature counters
Choose `first_open` vs. `session` from persisted, confirmed state. Keep sending
`first_open` until the server confirms (200/202) or definitively rejects it, and
make sure `isFirstCall` in the payload mirrors that selection.
**Never:** pick the endpoint from a raw launch counter that advanced before delivery.
Source: [IC-003](IC-003-counter-incremented-before-delivery.md)
