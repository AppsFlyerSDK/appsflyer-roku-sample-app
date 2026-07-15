---
commit: 9274247
year: 2023
feature_ref: [F-014]
---

## IC-001 — Logger reads a non-existent log file

**Component:** `AppsFlyerRokuSDK.brs` › `AppsFlyerLogger().log()`
**Bug class:** null-safety
**Severity:** LOW
**Ticket:** — (GitHub issues #1 and #2)
**Commit:** `9274247`
**Branch:** main
**Date:** 2023-03-23

### What Happened
The debug logger appended every message to `tmp:/aflog.txt` by first calling `ReadAsciiFile("tmp:/aflog.txt")` to load the existing contents — without checking whether the file existed yet. On the first log write of a fresh install (or after a reboot, since `tmp:/` is volatile) the file is absent.

### Observable Symptom
The very first log lines could be dropped from the persisted log, and the on-screen debug viewer (`OK` key) could show empty/`"Unable to read file"` content on first launch.

### Root Cause
`ReadAsciiFile` was called unconditionally; the code assumed `tmp:/aflog.txt` already existed. On Roku the `tmp:/` filesystem starts empty every session.

### Fix Applied
Guard the read with `MatchFiles("tmp:/", "aflog.txt")`. If `isLogExists.Count() = 0`, treat the current contents as `""` before appending the new line and writing the file back:

```brightscript
isLogExists = MatchFiles("tmp:/", "aflog.txt")
if isLogExists.Count() = 0
    afText = ""
else
    afText = ReadAsciiFile("tmp:/aflog.txt")
end if
```

### Takeaway
On Roku, never `ReadAsciiFile` a `tmp:/` path without first confirming existence via `MatchFiles` — the `tmp:/` filesystem is empty on first launch and after every reboot, so file reads must assume "not there yet."
