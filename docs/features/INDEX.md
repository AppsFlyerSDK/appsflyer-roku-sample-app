# AppsFlyer Roku Sample App — Feature Catalog

This catalog documents every discrete capability in the AppsFlyer Roku SDK
integration and its accompanying sample channel. The SDK lives in two
byte-identical copies:

- `appsflyer-integration-files/` — the drop-in files a host channel copies into its own project.
- `appsflyer-sample-app/` — a runnable demo channel that exercises the SDK end-to-end.

IDs are assigned in foundational order (F-001 = the public entry point). See
[`DIAGRAM.md`](./DIAGRAM.md) for cross-feature runtime, initialization, and
dependency views. See [`TEMPLATE.md`](./TEMPLATE.md) for the per-feature format.

## publicApi
The public `AppsFlyer()` facade and the lifecycle/config controls callers invoke directly.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-001](./F-001-sdk-public-api.md) | SDK Public API | active | Roku (BrightScript) |
| [F-002](./F-002-sdk-initialization.md) | SDK Initialization | active | Roku (BrightScript) |
| [F-013](./F-013-stop-opt-out.md) | Stop / Opt-Out | active | Roku (BrightScript) |
| [F-014](./F-014-logging-and-log-levels.md) | Logging & Log Levels | active | Roku (BrightScript) |

## measurement
Outbound event reporting to AppsFlyer and the shared payload those requests emit.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-007](./F-007-common-event-fields.md) | Common Event Fields Builder | active | Roku (BrightScript) |
| [F-009](./F-009-first-open-and-session-reporting.md) | First-Open & Session Reporting | active | Roku (BrightScript) |
| [F-010](./F-010-in-app-event-reporting.md) | In-App Event Reporting | active | Roku (BrightScript) |
| [F-011](./F-011-deep-link-tracking.md) | Deep Link Tracking | active | Roku (BrightScript) |

## attribution
Inbound conversion/attribution data returned by AppsFlyer after launch.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-012](./F-012-conversion-data-callback.md) | Conversion Data / Attribution Callback | active | Roku (BrightScript) |

## transport
The network layer that signs and delivers requests over HTTPS.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-008](./F-008-http-transport-and-signing.md) | HTTP Transport & Request Signing | active | Roku (BrightScript) |

## identityAndStorage
Device identity, persistence, and the counters/IDs that SDK state depends on.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-003](./F-003-persistent-registry-storage.md) | Persistent Registry Storage | active | Roku (BrightScript) |
| [F-004](./F-004-identifiers-and-time-utilities.md) | Identifiers & Time Utilities | active | Roku (BrightScript) |
| [F-005](./F-005-session-and-event-counters.md) | Session & Event Counters | active | Roku (BrightScript) |
| [F-006](./F-006-customer-user-id.md) | Customer User ID | active | Roku (BrightScript) |

## sampleApp
The runnable demo channel that boots and drives the SDK.

| ID | Name | Status | Platform |
|----|------|--------|----------|
| [F-015](./F-015-sample-app-bootstrap.md) | Sample App Bootstrap | active | Roku (BrightScript) |
| [F-016](./F-016-sample-app-remote-harness.md) | Sample App Remote Harness / Log Viewer | active | Roku (BrightScript) |
