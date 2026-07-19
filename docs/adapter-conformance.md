# Adapter Protocol 3.0.0 Alignment

Alignment date: 2026-07-19

Previous project version: **2.1.1**

Current project version: **3.0.0**

Canonical package: `../tui-tetris/protocol/adapter` (repository sibling). The
canonical files are consumed in place and are not copied into this project.

## Requirement matrix

| Protocol requirement | Current implementation | Migration difference resolved | Test evidence |
| --- | --- | --- | --- |
| Strict SemVer; all valid 3.x compatible; v2 rejected | Full SemVer parser; server reports 3.0.0 and compares the major version | Raised the compatible major from 2 to 3 and added an explicit legacy rejection | `testStrictSemVerAcceptsCompatibleThreeXAndRejectsMalformedVersion`, `testVersionTwoHandshakeIsExplicitlyRejected`, live v2 rejection check |
| Hello seq 1, JSON, supported command mode | Handshake validates all three and rejects duplicate hello | Existing 2.1 behavior retained | `testHelloSeqNotOneReceivesInvalidCommand`, codec/hello protocol tests |
| Deterministic welcome identity and capability policy | Required identity/controller fields; `events` and `logical_step` are always-on features | Removed `last_event`; advertised both new mandatory observation features | `testWelcomeEncodesRequiredIdentityAndCapabilityPolicyFields`, live welcome check |
| Every observation has authoritative `logical_step` | Core increments a monotonic logical step at transition start; restart preserves it | Added the Core-owned counter and wire field | `testLogicalStepAdvancesAtTransitionStartAndSurvivesRestart`, `testFixedTransitionBeginsBeforeAdapterCommandsAndAdvancement`, `testMapsSnapshotToObservation` |
| `events` is ordered, non-null, and contains 0...4 entries | Core captures lock outcomes in causal order and mapper always emits an array, capped at four | Replaced nullable singleton `last_event` with the bounded collection | `testSnapshotCarriesBoundedCausallyOrderedLockEvents`, `testMapsOrderedTransitionEventsWithoutLegacyLastEvent`, `testRemoteLockEventSurvivesUntilSameStepObservation` |
| Every ack has `correlation_seq` | Ack DTO always requires the triggering client sequence | Added correlation to control and game-command acknowledgements | `testAckShapesCarryCorrelationAndOnlyCommandAckCarriesAppliedState`, socket ack tests, live control check |
| Successful game-command ack has `applied_step` and `state_hash`; control ack omits both | SocketAdapter snapshots authoritative state after mutation for game ack; control ack uses correlation only | Added applied-state proof and distinct ack shapes | `testCommandAfterHelloReceivesAck`, `testRestartSeedAppliesDeterministicallyBeforeAck`, live command/control ack checks |
| Strict client sequencing; independent observation sequence | Per-client increasing seq; adapter-owned observation counter | Existing behavior retained; gaps remain legal | socket sequencing and throttle/coalescing tests |
| One controller; deterministic claim/release/promotion | Explicit release leaves unassigned; disconnect promotes lowest eligible client id | Existing behavior retained | `testObserverMayExplicitlyClaimUnassignedControl`, `testReleaseLeavesControlUnassignedUntilExplicitClaim`, `testDisconnectPromotionAndReconnectKeepSingleController`, live concurrency/reconnect check |
| Action max 32; deterministic restart; place failure atomic | Semantic validation, UInt32 seed, snapshot-based path planning | Existing behavior retained | `testActionLimitAndRestartPayloadSemanticsAreValidated`, `testRestartSeedAppliesDeterministicallyBeforeAck`, `CommandMappingTests`, canonical restart/determinism checks |
| Transition order is begin, drain/apply, advance, emit | SceneDriver opens the logical transition, polls commands, advances Core, then emits its snapshot | Moved transition bookkeeping before command application so command events and applied step describe the same transition | SceneDriver Adapter integration tests |
| Streaming hello gets an immediate full snapshot | Adapter retains and targets the latest complete observation after welcome | Existing behavior retained with new mandatory fields | `testStreamingHelloImmediatelyReceivesLatestFullSnapshot`, canonical ready check |
| Frames at most 65,536 bytes; bounded input/output; slow-client isolation | Incremental byte framer, 64-command default input bound, 256 KiB per-client output bound, observation coalescing | Existing behavior retained | framer tests, `testBackpressureRejectsCommand`, required-output overflow tests, live backpressure/frame/slow-client checks |
| Portable host/port/disabled controls | TCP profile defaults and environment overrides are project-local | Existing behavior retained | `AdapterBootstrapTests` |

## Changelog entries handled

- **3.0.0:** replaced nullable `last_event` with bounded ordered `events`;
  added authoritative `logical_step`; added `correlation_seq` to every ack;
  added `applied_step` and `state_hash` to successful game-command ack only;
  intentionally rejected v2 handshakes.
- The 2.1.0 and 2.1.1 requirements remain implemented: deterministic control
  policy, strict SemVer, bounded framing and queues, deterministic restart,
  immediate streaming snapshots, slow-client isolation, and reconnect cleanup.

## Verification caveat

Debug and Release application targets build with the installed macOS 15.5 SDK.
The canonical 3.0.0 `adapter_verify.py all` client passes ready, claim, restart,
and determinism. Separate live checks pass v2 rejection, ack-shape validation,
control concurrency, inbound backpressure/retry hints, the 65,536-byte frame
boundary, slow-client isolation, and disconnect/reconnect behavior.

The local CommandLineTools installation currently has no importable macOS
`XCTest` module, so `swift test` cannot compile any test target. The exact test
cases above remain the durable regression gate and must be rerun after repairing
the toolchain.
