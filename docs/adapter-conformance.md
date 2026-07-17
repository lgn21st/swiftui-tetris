# Adapter Protocol 2.1.1 Alignment

Alignment date: 2026-07-17

Previous project version: **2.0.0**

Current project version: **2.1.1**

Canonical package: `../tui-tetris/protocol/adapter` (repository sibling). The
canonical files are consumed in place and are not copied into this project.

## Requirement matrix

| Protocol requirement | Current implementation | Migration difference resolved | Test evidence |
| --- | --- | --- | --- |
| Strict SemVer; all valid 2.x compatible | Full SemVer parser; server reports 2.1.1 | Replaced first-component-only parsing and 2.0.0 report | `testStrictSemVerAcceptsCompatibleTwoXAndRejectsMalformedVersion`, `testHelloWithMismatchedMajorProtocolReceivesError` |
| Hello seq 1, JSON, supported command mode | Handshake validates all three and rejects duplicate hello | Added JSON/mode validation and duplicate-handshake guard | `testHelloSeqNotOneReceivesInvalidCommand`, codec/hello protocol tests |
| Deterministic welcome identity and capability policy | Required `client_id`, `role`, nullable `controller_id`; union plus always/optional features and control policy | Added all 2.1 welcome fields; only JSON is advertised | `testHelloReceivesWelcome`, `testWelcomeEncodesRequiredIdentityAndCapabilityPolicyFields` |
| Strict client sequencing; independent observation sequence | Per-client increasing seq; adapter-owned observation counter | Preserved client ordering and synchronized observation allocation; gaps remain legal | socket protocol sequencing tests, throttle/coalescing tests |
| One controller; observer not implicitly promoted; claim/release deterministic | Observer hello/auto-promotion excluded; explicit claim allowed; release leaves unassigned; disconnect promotes lowest eligible client id | Removed release-time promotion and observer-claim prohibition; advertised stable disconnect policy | `testObserverMayExplicitlyClaimUnassignedControl`, `testReleaseLeavesControlUnassignedUntilExplicitClaim`, `testDisconnectPromotionAndReconnectKeepSingleController` |
| Action max 32; restart parameters require restart; seed is UInt32 | Semantic validation plus `UInt32` DTO; seeded restart calls Core's deterministic restart before ack | Added action bound, restart object, semantic check, and fixed-seed application | `testActionLimitAndRestartPayloadSemanticsAreValidated`, `testRestartSeedAppliesDeterministicallyBeforeAck`, canonical `adapter_verify.py restart/determinism` |
| Place failure is atomic | Planner validates the complete action path against a snapshot before mutating authoritative state | Existing planning behavior retained and documented against 2.1.1 | `CommandMappingTests`, `testInvalidPlaceReceivesErrorAfterPoll` |
| Drain/apply, advance, emit; ack only after apply | SceneDriver polls before each Core fixed step and emits afterward; SocketAdapter acks after mutation | Existing order retained; initial snapshot priming added | `testAdapterCommandsApplyBeforeFixedStepBegins`, `testRestartSeedAppliesDeterministicallyBeforeAck` |
| Full observations; exactly five next pieces; state/board identifiers | ObservationMapper emits complete snapshot fields and canonical feature declarations | Added missing `board_id` and `ghost_y` capability declarations | `ObservationMappingTests`, `testStreamingHelloImmediatelyReceivesLatestFullSnapshot` |
| Streaming hello gets immediate full snapshot | SceneDriver primes latest snapshot; welcome is followed by a targeted observation | Added latest-snapshot retention and handshake delivery | `testStreamingHelloImmediatelyReceivesLatestFullSnapshot`, canonical `adapter_verify.py ready` |
| Frames at most 65,536 bytes; invalid UTF-8 not lossy | Incremental byte framer closes on 65,537 unterminated bytes; JSONDecoder rejects invalid UTF-8 | Reduced old 1 MiB limit to canonical 65,536 | `testLineFramerAcceptsCanonicalMaximumAndRejectsOneByteMore`, `testLineFramerRejectsInputBeyondConfiguredLimit` |
| Bounded inbound/outbound; reliable correlated responses; slow-client isolation | 64-command default inbound bound; 256 KiB per-client outbound frames; observations coalesce; required overflow disconnects only that client | Added positive retry hint and bounded per-client output | `testBackpressureRejectsCommand`, `testRequiredOutputOverflowDisconnectsOnlySlowClient`, `testTcpTransportWritesEntireLargeLine` |
| Portable host/port/disabled environment controls | Defaults/overrides follow TCP profile; disabled accepts `1` and `true` | Restored profile-defined host/port overrides and `true` parsing | `AdapterBootstrapTests` |
| Reconnect cleanup and closed-loop stability | Disconnect removes stale ownership, stable promotion applies, reconnect is a new client | Added explicit reconnect coverage | `testDisconnectPromotionAndReconnectKeepSingleController`, canonical repeated determinism check |

## Changelog entries handled

- **2.1.0:** deterministic identity/role/controller reporting; explicit control
  policy capabilities; always/optional feature partitions; optional retry hint.
- **2.1.1:** canonical current-package version; strict compatible SemVer;
  65,536-byte framing; legal observation gaps; reliable correlated delivery;
  clarified playability, atomic place, deterministic seeded restart, immediate
  streaming snapshot, slow-client isolation, and reconnect coverage.

## Verification caveat

Debug and Release application targets build with the installed macOS 15.5 SDK.
The canonical `adapter_verify.py all` client passes ready, claim, restart, and
determinism. Separate live checks pass control concurrency, inbound
backpressure/retry hints, the 65,536-byte frame boundary, slow-client
isolation, and disconnect/reconnect behavior.

The local CommandLineTools installation currently has no importable macOS
`XCTest` module, so `swift test` cannot compile any test target. The exact test
cases above remain the durable regression gate and must be rerun after repairing
the toolchain.
