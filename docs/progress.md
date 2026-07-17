# Progress Log

## 2026-07-17
- Completed a full documentation, architecture, correctness, and performance review; added `docs/evaluation.md` and restored a focused `docs/todo.md`.
- Fixed T-Spin classification to inspect lock-time geometry before line clearing shifts the board.
- Fixed next-piece and Hold spawning to refresh the ghost after the new active piece is assigned.
- Made `lineClearScore` include combo bonuses so renderer popups and Adapter `last_event` match the score delta.
- Preserved fixed-timestep semantics during catch-up frames by running input, Adapter polling, Core tick, and observation emission once per accumulated step.
- Ordered remote command polling before `beginFixedStep`, so pause/unpause and piece-changing commands receive correct step metadata.
- Reused immutable tetromino shape tables, Core ghost/landing buffers, and snapshot board storage in rendering.
- Replaced Adapter place-planner linear priority scans and path copies with a stable binary heap plus predecessor reconstruction.
- Added bounded 1 MiB line framing, ordered partial-write buffering, and `SO_NOSIGPIPE` to the TCP transport.
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
- Added protocol integration checklist to `docs/adapter.md`.
- Commands now ack after mapping/apply; invalid place/hold errors are surfaced to clients.
- Added adapter wire logging via `TETRIS_AI_LOG_PATH` (defaults to `auto`).

## 2026-02-01
- Bumped adapter protocol to v2.0.0 (breaking change; v1.0.0 dropped).
- Expanded `observation` payload with ML-ready fields: `episode_id`, `seed`, `piece_id`, `step_in_piece`, `next_queue`, `can_hold`, `last_event`, `state_hash`.
- Added mute toggle to silence SFX and ambient audio.

## 2026-02-04
- Made `docs/adapter.md` the single source of truth and aligned implementation strictly to it:
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
