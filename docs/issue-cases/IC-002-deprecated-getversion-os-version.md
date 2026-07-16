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
**Commit:** — (not yet fixed)
**Branch:** —
**Date:** 2025-11-10

### What Happened
The common-fields builder reads `device_ver = m.deviceInfo.GetVersion()` to populate the `device_os_version` payload field. On certain Roku devices this deprecated call returns the sentinel string `999.9999999` instead of a real firmware version.

### Observable Symptom
A large number of `roku`-platform conversion records in the datalake carry `os_version = 999.9999999` (confirmed by a `datalake.ott_conversions_matches` query). Any OS-based segmentation, targeting, or analytics for those devices is wrong.

### Root Cause
`roDeviceInfo.GetVersion()` is deprecated and unreliable across firmware versions. The SDK consumes its return value directly, with no validation and without using the supported replacement API.

### Fix Applied
Not yet fixed (Backlog). Recommended: read the OS version via the supported `roDeviceInfo.GetOSVersion()` (major/minor/revision/build) API, format it explicitly, and reject/clamp obviously-invalid sentinels (e.g. `999.*`) before sending.

### Takeaway
Treat every value read from a platform/device API as untrusted input: validate it against a sane range and prefer the currently-supported API (`GetOSVersion`) over deprecated ones (`GetVersion`). A "successful" call can still return a garbage sentinel.
