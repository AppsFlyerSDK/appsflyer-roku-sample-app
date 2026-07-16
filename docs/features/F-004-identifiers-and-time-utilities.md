---
id: F-004
name: Identifiers & Time Utilities
type: identityAndStorage
platform: Roku (BrightScript)
status: active
last_verified: 2026-07-15
depends_on: []
---

## Business Purpose
These helpers mint the identifiers and timestamps that make every AppsFlyer
request unique and correlatable. `generateAppsFlyerId` produces the stable
UUID-shaped device ID persisted on first launch; `generateGUID` produces a fresh
per-request `request_id`; `getAFTimestamp` stamps each payload; and
`AppsFlyerDateUtils.buildDate` formats the first-launch date and log timestamps.
Without them the backend could not deduplicate, order, or attribute events, and
the device would have no durable identity.

> Source: Derived from code. These identifier/time helpers are SDK-internal with no dedicated public AppsFlyer product doc.

---

## Trigger
Pure helper functions invoked on demand: at registry seeding (device ID,
first-launch date), on every outbound request (timestamp, request_id), and on
every log line (current time).

---

## Call Chain
```
AppsFlyerUtils().generateAppsFlyerId()   → getRandomHexString(n) × 5 → UUID-shaped string   [F-003 seeds UID]
AppsFlyerUtils().generateGUID()          → LCASE(getRandomHexString ...)                     [F-007 request_id]
AppsFlyerUtils().getAFTimestamp()        → roDateTime.AsSeconds()+GetMilliseconds()          [F-007 timestamp]
AppsFlyerUtils().incrementCounter(ref)   → ref.ToInt()++ → string                            [F-005]
AppsFlyerDateUtils().buildDate()         → formatted YYYY-MM-DD_HHMMSS±TZ                     [F-003 first-launch]
AppsFlyerDateUtils().getCurrentTime()    → HH:MM:SS:mmm                                       [F-014 log lines]
```

---

## Files
| File | Role |
|------|------|
| `appsflyer-integration-files/source/AppsFlyerRokuSDK.brs` | `AppsFlyerUtils`, `AppsFlyerDateUtils` |
| `appsflyer-sample-app/source/source/AppsFlyerRokuSDK.brs` | Identical utilities |

---

## Input / Output
| | |
|--|--|
| **Input** | Optional counter reference, hex length, date/time from `roDateTime` |
| **Output** | ID strings, GUIDs, timestamp strings, formatted dates |

---

## Tests
No automated tests exist in this repository.

---

## Known Limitations
- **`Rnd`-based ID generation is not cryptographically strong** — `getRandomHexString` uses `Rnd(16)` seeded per session; acceptable for an install ID but not a secret.
- **Dead code:** `getV1`/`getV2` hash helpers are present but marked *"remove before releasing"* and are never called; `httpEncode` and `getLangFromCode` are unused/commented.
- **`getTimeSinceLaunch` result is never sent** — it computes the interval and writes it back to the registry, but no request payload includes it.
- **`getRandomHexString` uses `Mid(str, Rnd(16)-1, 1)`** — off-by-one indexing risk depending on `Rnd` range.

---

## Dependencies
```mermaid
flowchart LR
    F004["F-004 · Identifiers and Time Utilities"]:::identityAndStorage
    classDef identityAndStorage fill:#7c3aed,color:#fff
```

_This is a leaf utility: it depends on nothing and is consumed by F-003, F-005, F-007, and F-014 (see those files and `DIAGRAM.md` for inbound edges)._
