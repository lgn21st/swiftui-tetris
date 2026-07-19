# Progress Log

## 2026-07-19
- Added a reusable `Headless` target and UI-free `TetrisServer` executable with monotonic absolute-deadline pacing, graceful signals, bounded runs, and safe fast/auto-restart soak options.
- Moved Adapter environment assembly below UI and added explicit throwing socket startup, so bind failures are observable and GUI/headless entry points share one policy.
- Passed the canonical Adapter 3.0.0 verifier for ten consecutive complete rounds against the Release headless server; a one-million-step Release soak completed in 0.18 seconds with 2,965,504 bytes maximum resident memory.
- Verified the resulting baseline with 289 Swift Testing tests across 92 suites.
- Began the clean-break architecture rebuild: added Xcode-independent CLI wrappers, migrated all 280 tests from XCTest to Swift Testing, and raised the supported deployment target to macOS 14 to match the Testing runtime.
- Verified all 280 tests across 91 suites plus Debug and Release CLI builds without Xcode.
- Added a pure-Swift `Runtime` target that owns the 16 ms accumulator, frame clamping, command/input ordering, Core advancement, and per-step snapshot publication.
- Removed `GameLoop`, Renderer `FixedStepClock`, and SpriteKit `onFixedStep`; the lean replacement baseline passes 276 tests across 89 suites.
- Made Runtime's mutable `GameState` private, queued local actions at the transaction boundary, made InputEngine state-free, and converted SceneDriver/HUD/focus handling to snapshot-only reads; 276 tests across 88 suites and both builds pass.
- Extracted Adapter identity/sequencing/control/promotion into a pure session registry, unified TCP and in-memory command mutation behind one executor, and isolated asynchronous JSONL logging from SocketAdapter.
- The refactored baseline passes 283 Swift Testing tests across 90 suites, including all protocol, transport, backpressure, disconnect, and reconnect cases.
- Bounded diagnostic logging at 64 pending best-effort records, reran the canonical 3.0.0 black-box verifier successfully, aligned packaged deployment metadata to macOS 14, and excluded Finder metadata from app resources.
- Raised the package manifest from Swift tools 5.9 to 6.2, isolated AppKit/SpriteKit coordinators on MainActor, documented queue-confined Sendable contracts, and reached warning-free Debug and Release builds.
- Split fixed-step transaction start from active-piece advancement so commands applied inside a logical transition determine whether that transition advances gameplay.
- Repaired the socket test client to retain bytes after a newline and to handle complete writes, exposing reliable protocol/backpressure evidence instead of timing-dependent tests.
- Upgraded the external Adapter from protocol 2.1.1 to canonical 3.0.0.
- Replaced nullable `last_event` with a non-null, causally ordered `events` array bounded to four entries and added Core-owned `logical_step` to every observation.
- Added mandatory ack correlation; successful game commands now prove applied state with `applied_step` and `state_hash`, while control ack intentionally omits game-state fields.
- Reordered fixed-transition bookkeeping so remote commands, emitted events, observations, and command ack all refer to the same logical transition.
- Added explicit v2 handshake rejection and updated the conformance matrix, project implementation profile, and Adapter development skills.
- Canonical ready/claim/restart/determinism and live concurrency/backpressure/frame/reconnect/slow-client checks passed before the current runtime rebuild; they remain mandatory gates for every batch.

## 2026-07-17
- Upgraded the external Adapter implementation from protocol 2.0.0 to canonical 2.1.1 and recorded the complete requirement/evidence matrix in `docs/adapter-conformance.md`.
- Added strict compatible SemVer, required welcome identities and feature partitions, explicit control policy, seeded restart, immediate handshake snapshots, and portable host/port/disable settings.
- Reduced TCP frame payloads to the canonical 65,536-byte maximum; bounded every client's outbound queue, coalesced superseded observations, isolated slow clients, and added positive backpressure retry hints.
- Added `docs/adapter-implementation-profile.md` for this project's queue, dispatch, scheduling, logging, promotion, and startup choices without copying `tui-tetris` implementation strategy.
- Completed a full documentation, architecture, correctness, and performance review; added `docs/evaluation.md` and restored a focused `docs/todo.md`.
- Fixed T-Spin classification to inspect lock-time geometry before line clearing shifts the board.
- Fixed next-piece and Hold spawning to refresh the ghost after the new active piece is assigned.
- Made `lineClearScore` include combo bonuses so renderer popups and the then-current Adapter `last_event` matched the score delta (3.0 now emits `events`).
- Preserved fixed-timestep semantics during catch-up frames by running input, Adapter polling, Core tick, and observation emission once per accumulated step.
- Ordered remote command polling before `beginFixedStep`, so pause/unpause and piece-changing commands receive correct step metadata.
- Reused immutable tetromino shape tables, Core ghost/landing buffers, and snapshot board storage in rendering.
- Replaced Adapter place-planner linear priority scans and path copies with a stable binary heap plus predecessor reconstruction.
- Added bounded framing, ordered partial-write buffering, and `SO_NOSIGPIPE` to the TCP transport; the later 2.1.1 alignment tightened the payload bound to 65,536 bytes.
- Replaced per-dequeue `removeFirst()` in the in-memory Adapter transport with indexed FIFO reads and amortized compaction.
- Reconciled focus-loss, queue depth, TCP-only transport, packaging, and runtime-layer documentation.
- Debug and Release builds pass with the macOS 15.5 SDK; targeted Core/Adapter checks and a 512 KiB localhost TCP write check also pass. Full XCTest execution is locally blocked because the active Command Line Tools installation lacks an importable macOS `XCTest` module.

## 2026-01-30
- Added Adapter layer for external AI control with TCP transport and JSON line framing.
- Wired Adapter into SceneDriver (poll before tick, emit after snapshot).
- Added protocol codec and mapping tests for command/observation flow.
- Added handshake/ack/error flow, idle timeout, and example client script for adapter testing.
- Added controller/observer support and stricter place command path validation.
- Added explicit control claim/release, observation throttling, and command backpressure handling.
- Added path-based place planner (SRS kick aware), auto-promotion of observers, and protocol JSON schema.
- Added adapter environment overrides for idle timeout, command backpressure, and observation throttling.
- Documented adapter env examples and added protocol message examples.
- Adapter now defaults to TCP localhost (127.0.0.1:7777) on startup when no env vars are set.
- Added `TETRIS_AI_DISABLED` to disable adapter startup.
- Losing focus no longer auto-pauses the game; input is still reset.
- Added the original protocol integration checklist (the retired local protocol document was later replaced by the canonical external package and current conformance/profile docs).
- Commands now ack after mapping/apply; invalid place/hold errors are surfaced to clients.
- Added adapter wire logging via `TETRIS_AI_LOG_PATH` (defaults to `auto`).

## 2026-02-01
- Bumped adapter protocol to v2.0.0 (breaking change; v1.0.0 dropped).
- Expanded `observation` payload with ML-ready fields: `episode_id`, `seed`, `piece_id`, `step_in_piece`, `next_queue`, `can_hold`, `last_event`, `state_hash`.
- Added mute toggle to silence SFX and ambient audio.

## 2026-02-04
- Made the then-current local adapter document the source of truth (superseded by the canonical `tui-tetris/protocol/adapter` package during the 2.1.1 migration):
  - enforced `hello.seq == 1` and strictly increasing `seq` per connection
  - implemented `requested.role` semantics and controller eligibility
  - aligned `observation` encoding (`board_id`, `cells` 0..7, `next_queue` length 5, optional `last_event`/`ghost_y`)
- Removed adapter host/port overrides; transport is fixed to `127.0.0.1:7777` per standard.

## 2026-01-22
- Removed soft drop trail (code + tests) and updated docs.
- Restored landing flash outline with timer‑based alpha.
- Ghost guidance now appears only after a successful move since spawn.
- Line‑clear pause hides active and ghost layers.
- Added render guard to avoid SKView drawable warnings.
- Renderer optimizations: incremental buffer updates, render skip on no changes.
- Prewarmed textures and capped popup nodes; fixed 4‑node active overlay.
- Diagnostics updates throttled (~5Hz).
- Folded the beginner guide into `docs/architecture.md` and merged todo into roadmap.

## 2026-01-21
- HUD typography and layout improvements; hold/next in footer.
- Window defaults and scaling behavior stabilized.
- Audio loop/ducking and diagnostics overlay refined.
