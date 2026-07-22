---
commit: —
year: 2025
feature_ref: [F-007]
---

## IC-002 — Deprecated `GetVersion()` yields `999.9999999` OS version

**Component:** `AppsFlyerRokuSDK.brs` › `AppsFlyerCore().af_commonFields` (`device_os_version`)
**Bug class:** api-contract
**Severity:** MEDIUM
**Ticket:** DELIVERY-106204 (P2 Bug, Backlog)
**Commit:** — (pending)
**Branch:** DELIVERY-106204-fix-os-issue
**Date:** 2025-11-10

### What Happened
The common-fields builder reads `device_ver = m.deviceInfo.GetVersion()` to populate the `device_os_version` payload field. On certain Roku devices this deprecated call returns the sentinel string `999.9999999` instead of a real firmware version.

### Observable Symptom
A large number of `roku`-platform conversion records in the datalake carry `os_version = 999.9999999` (confirmed by a `datalake.ott_conversions_matches` query). Any OS-based segmentation, targeting, or analytics for those devices is wrong.

### Root Cause
`roDeviceInfo.GetVersion()` is deprecated and unreliable across firmware versions. The SDK consumes its return value directly, with no validation and without using the supported replacement API.

### Fix Applied
Fixed on branch `DELIVERY-106204-fix-os-issue`. `af_commonFields` now sources
`device_os_version` via a new `af_getOsVersionString` helper that reads the
supported `roDeviceInfo.GetOSVersion()`, composes `major.minor.revision` (build
excluded), and falls back to `""` when `GetOSVersion()` returns `invalid`/empty.
Switching off the deprecated `GetVersion()` removes the masked `999.*` placeholder
at the source — `GetOSVersion()` returns real, structured values — so no explicit
sentinel check is kept. Crash-safety guards remain: `invalid`/empty `major` yields
`""`. `minor`/`revision` were added to `GetOSVersion()` after its 9.2 debut (per
Roku OS release notes), so on older firmware they can be absent; a missing octet
is omitted by truncating at the first gap (e.g. `15.3` or `15`), never zero-filled
and never emitted as a gapped string — which also avoids a `string + invalid`
concatenation that would abort `af_commonFields` (which runs on every launch and
event — GR-01). (`GetOSVersion()` requires Roku OS 9.2+; pre-9.2 firmware is out
of the supported range.) Mirrored across both SDK copies; verified on a physical
Roku (OS `15.3.4`) by inspecting the request body.

### Takeaway
Treat every value read from a platform/device API as untrusted input: validate it against a sane range and prefer the currently-supported API (`GetOSVersion`) over deprecated ones (`GetVersion`). A "successful" call can still return a garbage sentinel.
