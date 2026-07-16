---
id: F-003
name: Persistent Registry Storage
type: identityAndStorage
platform: Roku (BrightScript)
status: active
last_verified: 2026-07-15
depends_on: [F-004]
---

## Business Purpose
The Roku registry is the SDK's only durable memory. `AppsFlyerRegistry` persists
everything that must survive a channel restart: the developer key and app ID,
the stable AppsFlyer device ID, the session and in-app-event counters, the log
level, the first-launch date, and the cached conversion response. This
persistence is what makes attribution correct — the same device keeps the same
ID across launches, the session counter distinguishes first-open from returning
sessions, and credentials do not have to be re-supplied. Remove it and every
launch would look like a brand-new install.

> Source: Derived from code. Persistence via the Roku registry is an SDK-internal mechanism with no dedicated public AppsFlyer product doc.

---

## Trigger
- `AppsFlyerRegistry().init(devKey, appId)` during `init` seeds any missing keys (first launch).
- `get`/`set` are called throughout the SDK whenever state must be read or persisted (counters, log level, conversion cache, IDs).

---

## Call Chain
```
AppsFlyerRegistry().init(devKey, appId)                 [AppsFlyerRokuSDK.brs]
  → set(DEVKEY/AFAPPID)                                  if missing
  → set(LOGLEVEL = "error")                              if missing
  → set(UID = LCASE(AppsFlyerUtils().generateAppsFlyerId()))   [F-004] if missing
  → set(SESSIONCOUNTER=0 / IAECOUNTER=0)                if missing
  → set(FIRSTLAUNCHDATE = AppsFlyerDateUtils().buildDate())    [F-004] if missing
  → set(TIMESINCELAUNCH = roDateTime.asSeconds())       if missing

get(key) / set(key,value)
  → regId = REGPREFIX + APP_ID_PREFIX + roAppInfo.GetID()
  → CreateObject("roRegistrySection", regId).Read/Write + Flush
```

---

## Files
| File | Role |
|------|------|
| `appsflyer-integration-files/source/AppsFlyerRokuSDK.brs` | `AppsFlyerRegistry` (init/get/set), `RegistryConstants` |
| `appsflyer-sample-app/source/source/AppsFlyerRokuSDK.brs` | Identical registry logic |
| `appsflyer-sample-app/source/source/Main.brs` | `deleteReg()` dev helper that clears registry sections |

---

## Input / Output
| | |
|--|--|
| **Input** | Registry key + value strings; `roAppInfo.GetID()` for the section name |
| **Output** | Persisted values in registry section `AppsFlyerRegistry.roku.<channelId>` |

---

## Tests
No automated tests exist in this repository. `deleteReg()` in `Main.brs` is a manual reset aid for local testing.

---

## Known Limitations
- **Section name keyed on `roAppInfo.GetID()`** — a sideloaded channel reports `dev`, so a sideloaded build and a published build use different registry sections and different device IDs.
- **Duplicated `TIMESINCELAUNCH` seed block** — `init` contains the same `TIMESINCELAUNCH` guard twice (dead duplicate).
- **No size/consent guard** — values (including cached conversion data) persist indefinitely with no eviction and no opt-out clearing.

---

## Dependencies
```mermaid
flowchart LR
    F003["F-003 · Persistent Registry Storage"]:::identityAndStorage -->|"seeds device ID and first-launch date via"| F004["F-004 · Identifiers and Time Utilities"]:::identityAndStorage
    classDef identityAndStorage fill:#7c3aed,color:#fff
```
