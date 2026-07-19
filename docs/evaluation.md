# Comprehensive Project Evaluation

Last reviewed: 2026-07-19

## Executive Summary

The project has a sound separation between deterministic Core rules, SpriteKit rendering, SwiftUI coordination, and the optional Adapter. The review found no reason for a wholesale rewrite. It did find correctness and transport defects at subsystem boundaries plus several avoidable hot-path allocations; those issues were fixed in this review.

Current assessment:

| Area | Assessment | Evidence |
| --- | --- | --- |
| Core correctness | Strong after fixes | Deterministic state, rules tests, lock-time T-Spin fix |
| Architecture | Strong | Core has no UI dependency; Renderer maps snapshots; SceneDriver coordinates |
| Rendering | Strong | Preallocated nodes, texture cache, incremental cell buffer, direct snapshot board reuse |
| Input/timing | Strong after fixes | DAS/ARR isolation and per-step catch-up processing |
| Adapter | Aligned to 3.0.0 | Conformance matrix, logical transitions/events, applied-state ack, bounded transport |
| Documentation | Reconciled | Canonical protocol is external; local implementation profile and project docs agree |
| Verification environment | Needs repair | Debug/Release builds work; local Command Line Tools lacks macOS XCTest module |

## Correctness Findings Resolved

1. T-Spin detection ran after `clearLines()`. Row shifting could erase the corner geometry and under-score a valid T-Spin. Detection now occurs immediately before locking and clearing.
2. `lineClearScore` captured base/B2B points before combo was added. UI popups and Adapter events could disagree with the score delta. It now records the complete award.
3. Catch-up frames passed several fixed steps to Core as one large elapsed interval and incremented Adapter step state once. SceneDriver now runs every accumulated step independently.
4. Documentation said focus loss auto-paused, while implementation and tests intentionally only reset held input. The authoritative docs now match runtime behavior.
5. Spawn logic refreshed the ghost cache before assigning the new active piece. Next/Hold spawns now refresh after assignment, preventing a one-action stale ghost.

## Performance Findings Resolved

1. `Tetromino.blocks` rebuilt the complete 7 x 4 nested shape table on every collision, ghost, render, and planning query. The table is now immutable process-wide storage.
2. Render mapping allocated a new 10 x 20 optional-kind board every frame. RenderState now shares the snapshot's copy-on-write `[[Cell]]` storage.
3. Ghost and landing-flash block arrays now retain their four-element capacity.
4. Place planning used repeated linear minimum searches, middle-array removals, and copied the full action path for each frontier node. It now uses a stable binary min-heap and predecessor reconstruction.
5. In-memory Adapter queues no longer shift all remaining elements on every dequeue.

## Reliability and Security Findings Resolved

1. Nonblocking socket writes previously ignored short writes and `EAGAIN`, silently truncating JSON lines. Each connection now owns an ordered output buffer drained by a write dispatch source.
2. TCP input buffering had no line-size limit. Protocol lines are capped at 65,536 payload bytes and over-limit connections are closed.
3. Accepted sockets now use `SO_NOSIGPIPE`, preventing a disconnected client from terminating the app during output.
4. Per-client output is capped at 256 KiB. Observations coalesce, while a required-response overflow closes only the affected connection instead of silently dropping a correlated message.

## Structure Review

- `Core`: correct owner for board, pieces, RNG, scoring, timing, actions, and snapshots.
- `Renderer`: contains mapping, clocks, node reuse, textures, and visual-only state; it does not mutate gameplay.
- `UI`: contains SceneDriver, input devices, audio, views, window behavior, and derived HUD/overlay state.
- `Adapter`: contains protocol DTOs, command planning, observations, framing, and transport.
- `Packaging`/`App`: remain thin entry and delivery layers.

Large files (`TetrisAIProtocol.swift`, `SocketAdapter.swift`, and `GameState.swift`) are cohesive enough to retain for now. Splitting them without a behavioral need would add navigation overhead; future extraction thresholds are tracked in `docs/todo.md`.

## Verification Record

- `swift build` and `swift build -c release` with macOS 15.5 SDK: passed after the protocol 3.0.0 migration.
- Canonical Adapter black-box checks passed: ready, claim, restart, and fixed-seed determinism.
- Live Adapter stress checks passed: control concurrency, inbound backpressure/retry hints, frame-boundary disconnect, slow-client isolation, and disconnect/reconnect ownership.
- Targeted executable checks: passed for T-Spin scoring, combo event score, spawn ghost refresh, shape invariants, framing limit, planner depth, and a 512 KiB localhost TCP write.
- `git diff --check`: passed after all edits.
- `swift test`: blocked before test compilation because the active Command Line Tools installation has no importable macOS `XCTest` module. This is an environment/toolchain defect, not a test failure.

## Residual Risks

- Automated tests must be rerun once XCTest is restored; the newly added socket stress test is particularly important.
- Adapter queue capacities are implementation-local defaults and should be load-tested before exposing the endpoint beyond a trusted local interface.
- Performance changes are complexity/allocation improvements validated by code inspection and builds, not Instruments measurements. Capture Instruments baselines before making claims about FPS or latency percentages.
