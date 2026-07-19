# Architecture & Design Review (SwiftUI + SpriteKit)

This document defines the target architecture and refactor plan for a SwiftUI + SpriteKit-native Tetris, without porting constraints. The goal is to maximize responsiveness, maintainability, and testability while using platform-appropriate patterns.

## Beginner Overview
This section explains the codebase in plain language for new contributors.

### Big Picture
The project is split into six layers:
1) Core (rules and state)
2) Runtime (headless fixed-step transactions)
3) Headless (standalone runtime scheduling and lifecycle)
4) Renderer (SpriteKit drawing)
5) UI (SwiftUI views, input, audio)
6) Adapter (protocol/transport boundary for external AI clients)

Flow:
```
Input (keyboard/gamepad)
        -> Runtime transaction
        -> Core state updates
        -> RenderState snapshot
        -> SpriteKit draws
        -> SwiftUI overlays HUD

External AI (tetris-ai)
        -> Adapter (command mapping)
        -> Headless server scheduling
        -> Runtime transaction
        -> Core state updates
        -> Snapshot mapping
        -> Adapter (observation streaming)
```

Executable targets are the composition roots. `App` may assemble UI and
Adapter, while UI depends only on Core, Runtime, and Renderer. `TetrisServer`
assembles Adapter and Headless directly. UI never imports the protocol layer.

### Folder Map
```
Core/               Game rules and data (no UI)
Runtime/            Accumulator, transaction ordering, snapshots
Headless/           Monotonic scheduling and UI-free server lifecycle
Renderer/           SpriteKit rendering and textures
Sources/UI/         SwiftUI views, input, audio, SceneDriver
Adapter/            Local TCP protocol, command planning, observations
Tests/              Unit + integration tests
assets/             Audio files, icons
```

Where to edit:
- Rules, scoring, timing -> Core/
- Fixed-step scheduling and command ordering -> Runtime/
- Standalone scheduling and shutdown policy -> Headless/
- Visual appearance -> Renderer/
- HUD, overlays, inputs, audio -> Sources/UI/

### Game Loop (Simple View)
- TetrisScene.update(_:) runs every frame.
- TetrisScene reports clamped frame time; it owns no gameplay clock.
- GameRuntime accumulates frame time and advances Core in independent 16ms transactions, including catch-up frames.
- Rendering happens after logic.
- Runtime begins a logical transition, polls Adapter commands, advances that fixed step, and emits its snapshot.
- `TetrisServer` drives one Runtime transaction per absolute monotonic 16 ms deadline; a delay beyond 250 ms rebases the deadline instead of creating an unbounded catch-up burst.

### External AI Transport
- Adapter implements canonical Tetris AI Adapter Protocol 3.0.0; the normative package lives in the sibling `tui-tetris/protocol/adapter` directory.
- TCP defaults to `127.0.0.1:7777`; portable profile overrides are `TETRIS_AI_HOST` and `TETRIS_AI_PORT`.
- Transport is line-delimited JSON (one message per line).
- Clients must send `hello` before `command`; server replies with `welcome`, then `ack`/`error` for commands.
- Normative role/sequencing rules come from the canonical package; project-local runtime choices are in `docs/adapter-implementation-profile.md`.
- Control messages allow explicit claim/release:
  - `control(action=claim)` claims control if none exists.
  - `control(action=release)` releases control (controller-only).
- Explicit release leaves control unassigned. Controller disconnect promotes the lowest-client-id eligible auto/controller client; explicit observers are never auto-promoted.
- Adapter enforces bounded inbound and per-client outbound queues; command saturation returns `backpressure` plus a positive retry hint.
- Observation streaming can be throttled by interval (configurable).
- Idle connections close after ~2s by default (configurable in Adapter).
- Runtime config via environment:
  - `TETRIS_AI_LOG_PATH=/tmp/tetris-ai-adapter.jsonl` (default `auto`)
  - `TETRIS_AI_IDLE_TIMEOUT_MS=2000` (set `0` to disable)
  - `TETRIS_AI_MAX_PENDING=64`
  - `TETRIS_AI_MAX_OUTBOUND_BYTES=262144`
  - `TETRIS_AI_BACKPRESSURE_RETRY_MS=50`
  - `TETRIS_AI_OBSERVATION_MS=0` (set `0` to disable)

### Tests (TDD)
1) Add or update a test in Tests/.
2) Implement the change in code.
3) Run `scripts/test`.

### Common CLI Commands
- Tests: `scripts/test`
- Run: `scripts/run`
- Run headless server: `scripts/server`
- Build (debug): `scripts/build`
- Build (release): `scripts/build -c release`

## Principles
- **Runtime owns game transactions**: Core commands, fixed-step advancement, events, snapshots, and Adapter acknowledgements share one deterministic boundary.
- **SpriteKit owns frame pacing only**: `SKScene.update(_:)` supplies elapsed time and renders the latest immutable state.
- **SwiftUI owns composition**: overlays, HUD, and window behaviors should be SwiftUI-first.
- **Core is deterministic**: all rule changes are test-first and isolated from rendering/input.
- **Bounded hot-path allocation**: reuse nodes, buffers, cached shape tables, textures, and Core board storage; transient four-block overlay arrays remain intentionally small.
- **Assets are packaged explicitly**: `Packager` copies `assets/`; `AssetLocator` resolves packaged and CLI layouts consistently.

## Status
- The headless Runtime and standalone server, private mutable-state boundary,
  Swift Testing migration, and Adapter transport/session/execution decomposition
  are complete.

## Target Architecture
### Loop & Timing
- A UI-agnostic runtime becomes the authoritative owner of the 16 ms accumulator and fixed-step transaction.
- Each transaction begins a logical step, applies local and Adapter commands, advances Core once, captures events, then publishes one snapshot and correlated Adapter result.
- Local UI actions are queued; InputEngine produces actions without seeing `GameState`, and changes become visible at the next fixed transaction.
- `SceneDriver` becomes a thin platform coordinator for input, audio, rendering, and lifecycle.
- Headless tests and external controllers drive the same runtime API as SpriteKit.

### Rendering
- Pre-allocate node grids for board + ghost + effects.
- Use a render buffer to track changed and flash cells without per-frame allocations.
- Update only nodes whose cell state changed, plus flash cells when flash alpha changes.
- Use cached `SKTexture`s for each tetromino color to avoid per-frame drawing.

### Input
- Create a single `InputRouter` that maps keyboard/gamepad to `GameAction`.
- Support SwiftUI `Commands` for minimal menu actions (Pause, Restart).
- Keep key capture and gamepad handling decoupled from gameplay logic.

### Audio
- Migrate to `AVAudioEngine` with preloaded `AVAudioPCMBuffer`s.
- Mix per-event gain and master volume in a single audio mixer.
- Guarantee low-latency playback for rapid events (move/rotate).

### SwiftUI Composition
- Keep `SpriteView` fixed-size in logical coordinates and scale via SwiftUI.
- Overlay HUD with `ZStack`.
- Provide accessibility: reduce motion, keyboard focus order, and legible text sizes.

## Current Alignment
- Fixed-step ownership lives in `GameRuntime`; `TetrisScene.update(_:)` only reports frame time and renders.
- Standalone scheduling lives in `HeadlessServer`; it reuses the same Runtime transaction API and imports no UI framework.
- Render pipeline reuses buffers/nodes and caches textures.
- Render mapping passes Core board cells through copy-on-write storage instead of allocating a 10x20 kind projection every frame.
- Tetromino shapes are an immutable process-wide table; collision and planning queries do not rebuild it.
- Input routed through `InputRouter` for keyboard + gamepad consistency.
- Audio uses `AVAudioEngine` with preloaded buffers.
- UI polish includes commands, overlays, focus pause handling, and accessibility coverage.
- Adapter framing is bounded to 65,536 payload bytes; nonblocking per-client output is bounded to 256 KiB and queues partial writes until complete.
- Adapter session/control policy and command execution are transport-free, independently tested components; SocketAdapter only coordinates wire messages, bounded queues, and Runtime delivery.

## Testing Strategy
- Core tests remain the contract for rules and timing.
- Runtime tests cover headless accumulation, frame clamping, catch-up, transaction ordering, and snapshot publication.
- UI integration tests cover action production, input routing, snapshot-derived HUD, and overlay state.
- Renderer tests validate mapping logic and resource reuse.
- Adapter tests cover protocol, concurrency, bounded backpressure, disconnect, and reconnect behavior through public boundaries.
- Swift Testing is the only test framework; XCTest and Xcode projects are intentionally absent.
- Swift tools 6.2 is the package language mode. AppKit/SpriteKit coordination is main-actor isolated; Adapter queue confinement is expressed with narrow Sendable contracts.

## Risks
- Migrating the loop can change timing; guard with deterministic tests.
- Audio engine changes may affect latency; validate with quick repeat actions.
- Input refactor can cause regressions; maintain exhaustive mapping tests.
