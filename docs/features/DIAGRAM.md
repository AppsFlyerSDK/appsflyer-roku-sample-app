# AppsFlyer Roku Sample App — Feature Diagrams

Aggregated cross-feature views built from the `depends_on` frontmatter and the
per-feature mermaid edges. See [`INDEX.md`](./INDEX.md) for the feature list.

Categories and colors:
- `publicApi` — indigo `#4f46e5`
- `measurement` — blue `#0284c7`
- `attribution` — amber `#d97706`
- `transport` — green `#059669`
- `identityAndStorage` — purple `#7c3aed`
- `sampleApp` — pink `#db2777`

---

## Section 1 — Runtime Flow

```mermaid
flowchart TD
    subgraph sampleApp_g [sampleApp]
        F015["F-015<br/>Sample App Bootstrap"]:::sampleApp
        F016["F-016<br/>Remote Harness / Log Viewer"]:::sampleApp
    end

    subgraph publicApi_g [publicApi]
        F001["F-001<br/>SDK Public API"]:::publicApi
        F002["F-002<br/>SDK Initialization"]:::publicApi
        F013["F-013<br/>Stop / Opt-Out"]:::publicApi
        F014["F-014<br/>Logging and Log Levels"]:::publicApi
    end

    subgraph measurement_g [measurement]
        F007["F-007<br/>Common Event Fields"]:::measurement
        F009["F-009<br/>First-Open and Session"]:::measurement
        F010["F-010<br/>In-App Event Reporting"]:::measurement
        F011["F-011<br/>Deep Link Tracking"]:::measurement
    end

    subgraph attribution_g [attribution]
        F012["F-012<br/>Conversion Data Callback"]:::attribution
    end

    subgraph transport_g [transport]
        F008["F-008<br/>HTTP Transport and Signing"]:::transport
    end

    subgraph identityAndStorage_g [identityAndStorage]
        F003["F-003<br/>Persistent Registry Storage"]:::identityAndStorage
        F004["F-004<br/>Identifiers and Time Utilities"]:::identityAndStorage
        F005["F-005<br/>Session and Event Counters"]:::identityAndStorage
        F006["F-006<br/>Customer User ID"]:::identityAndStorage
    end

    F001 --> F002
    F001 --> F006
    F001 --> F009
    F001 --> F010
    F001 --> F011
    F001 --> F013
    F001 --> F014
    F002 --> F003
    F002 --> F014
    F003 --> F004
    F005 --> F003
    F005 --> F004
    F006 --> F002
    F006 --> F014
    F007 --> F002
    F007 --> F004
    F007 --> F006
    F008 --> F003
    F008 --> F014
    F009 --> F002
    F009 --> F005
    F009 --> F007
    F009 --> F008
    F010 --> F002
    F010 --> F005
    F010 --> F007
    F010 --> F008
    F011 --> F007
    F011 --> F009
    F012 --> F003
    F012 --> F008
    F012 --> F009
    F013 --> F002
    F013 --> F014
    F014 --> F003
    F014 --> F004
    F015 --> F001
    F015 --> F012
    F015 --> F016
    F016 --> F001
    F016 --> F014

    classDef publicApi fill:#4f46e5,color:#fff
    classDef measurement fill:#0284c7,color:#fff
    classDef attribution fill:#d97706,color:#fff
    classDef transport fill:#059669,color:#fff
    classDef identityAndStorage fill:#7c3aed,color:#fff
    classDef sampleApp fill:#db2777,color:#fff
```

---

## Section 2 — Initialization Flow

Only the features that configure, seed, or boot other features at startup. The
measurement, deep-link, and attribution nodes are excluded because they run on
user/launch actions, not during boot.

```mermaid
flowchart LR
    F015["F-015 · Sample App Bootstrap"]:::sampleApp -->|"calls init through facade"| F001["F-001 · SDK Public API"]:::publicApi
    F001 -->|"dispatches init to"| F002["F-002 · SDK Initialization"]:::publicApi
    F002 -->|"persists credentials and seeds state in"| F003["F-003 · Persistent Registry Storage"]:::identityAndStorage
    F003 -->|"seeds device ID and first-launch date via"| F004["F-004 · Identifiers and Time Utilities"]:::identityAndStorage
    F002 -->|"initializes logging via"| F014["F-014 · Logging and Log Levels"]:::publicApi
    F014 -->|"persists default log level in"| F003
    F014 -->|"timestamps lines via"| F004
    classDef publicApi fill:#4f46e5,color:#fff
    classDef identityAndStorage fill:#7c3aed,color:#fff
    classDef sampleApp fill:#db2777,color:#fff
```

---

## Section 3 — Dependency Table

| Feature | Depends On | Note |
|---------|------------|------|
| F-001 SDK Public API | F-002 SDK Initialization | Routes `init()` to the initialization logic |
| F-001 SDK Public API | F-006 Customer User ID | Routes `setCustomerUserId()` |
| F-001 SDK Public API | F-009 First-Open and Session | Routes `start()` |
| F-001 SDK Public API | F-010 In-App Event Reporting | Routes `logEvent()` |
| F-001 SDK Public API | F-011 Deep Link Tracking | Routes `trackDeepLink()` |
| F-001 SDK Public API | F-013 Stop / Opt-Out | Routes `stop()` |
| F-001 SDK Public API | F-014 Logging and Log Levels | Routes `enableDebugLogs()`/`setLogLevel()` |
| F-002 SDK Initialization | F-003 Persistent Registry Storage | Persists credentials and reads persisted globals |
| F-002 SDK Initialization | F-014 Logging and Log Levels | Logs initialization progress |
| F-003 Persistent Registry Storage | F-004 Identifiers and Time Utilities | Seeds the device ID and first-launch date on first run |
| F-005 Session and Event Counters | F-003 Persistent Registry Storage | Persists the session and in-app-event counters |
| F-005 Session and Event Counters | F-004 Identifiers and Time Utilities | Increments counters via `incrementCounter` |
| F-006 Customer User ID | F-002 SDK Initialization | Rebuilds globals before storing the CUID |
| F-006 Customer User ID | F-014 Logging and Log Levels | Logs when the CUID is set or rejected |
| F-007 Common Event Fields Builder | F-002 SDK Initialization | Reads IDs, app version, and endpoints from globals |
| F-007 Common Event Fields Builder | F-004 Identifiers and Time Utilities | Stamps `request_id` and `timestamp` |
| F-007 Common Event Fields Builder | F-006 Customer User ID | Adds `customer_user_id` when one is set |
| F-008 HTTP Transport and Signing | F-003 Persistent Registry Storage | Reads the devKey to compute the HMAC signature |
| F-008 HTTP Transport and Signing | F-014 Logging and Log Levels | Logs request URL, body, and response code |
| F-009 First-Open and Session | F-002 SDK Initialization | Reads globals and the endpoint URLs |
| F-009 First-Open and Session | F-005 Session and Event Counters | Uses the session counter to pick first-open vs session |
| F-009 First-Open and Session | F-007 Common Event Fields Builder | Builds the launch payload |
| F-009 First-Open and Session | F-008 HTTP Transport and Signing | Sends the signed launch request |
| F-010 In-App Event Reporting | F-002 SDK Initialization | Reads globals |
| F-010 In-App Event Reporting | F-005 Session and Event Counters | Increments the in-app-event counter |
| F-010 In-App Event Reporting | F-007 Common Event Fields Builder | Builds the event payload |
| F-010 In-App Event Reporting | F-008 HTTP Transport and Signing | Sends the signed event request |
| F-011 Deep Link Tracking | F-007 Common Event Fields Builder | Decorates the payload with `af_deeplink` |
| F-011 Deep Link Tracking | F-009 First-Open and Session | Reuses the launch-reporting code path |
| F-012 Conversion Data Callback | F-003 Persistent Registry Storage | Caches the conversion payload |
| F-012 Conversion Data Callback | F-008 HTTP Transport and Signing | Issues the conversion follow-up request |
| F-012 Conversion Data Callback | F-009 First-Open and Session | Triggered by the session/first-open response |
| F-013 Stop / Opt-Out | F-002 SDK Initialization | Rebuilds globals before flipping `isStopped` |
| F-013 Stop / Opt-Out | F-014 Logging and Log Levels | Logs that the SDK stopped |
| F-014 Logging and Log Levels | F-003 Persistent Registry Storage | Persists and reads the configured log level |
| F-014 Logging and Log Levels | F-004 Identifiers and Time Utilities | Timestamps each log line |
| F-015 Sample App Bootstrap | F-001 SDK Public API | Initializes the SDK through the facade |
| F-015 Sample App Bootstrap | F-012 Conversion Data Callback | Receives conversion data in its message loop |
| F-015 Sample App Bootstrap | F-016 Remote Harness / Log Viewer | Launches the `AppsFlyerScene` |
| F-016 Remote Harness / Log Viewer | F-001 SDK Public API | Invokes public methods from remote-key presses |
| F-016 Remote Harness / Log Viewer | F-014 Logging and Log Levels | Renders the log file the logger produces |
