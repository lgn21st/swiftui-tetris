# Architecture & Design Review (SwiftUI + SpriteKit)

This document defines the target architecture and refactor plan for a SwiftUI + SpriteKit-native Tetris, without porting constraints. The goal is to maximize responsiveness, maintainability, and testability while using platform-appropriate patterns.

## Beginner Overview
This section explains the codebase in plain language for new contributors.

### Big Picture
The game is split into three layers:
1) Core (rules and state)
2) Renderer (SpriteKit drawing)
3) UI (SwiftUI views, input, audio)
4) Adapter (protocol/transport boundary for external AI clients)

Flow:
```
Input (keyboard/gamepad)
        -> Core state updates
        -> RenderState snapshot
        -> SpriteKit draws
        -> SwiftUI overlays HUD

External AI (tetris-ai)
        -> Adapter (command mapping)
        -> Core state updates
        -> Snapshot mapping
        -> Adapter (observation streaming)
```

### Folder Map
```
Core/               Game rules and data (no UI)
Renderer/           SpriteKit rendering and textures
Sources/UI/         SwiftUI views, input, audio, SceneDriver
Tests/              Unit + integration tests
assets/             Audio files, icons
```

Where to edit:
- Rules, scoring, timing -> Core/
- Visual appearance -> Renderer/
- HUD, overlays, inputs, audio -> Sources/UI/

### Game Loop (Simple View)
- TetrisScene.update(_:) runs every frame.
- A fixed timestep clock advances Core logic (16ms).
- Rendering happens after logic.
 - Adapter polls for commands before each fixed step and emits observations after snapshot.

### External AI Transport
- Adapter can listen on Unix domain sockets or TCP localhost.
- Transport is line-delimited JSON (one message per line).
- Clients must send `hello` before `command`; server replies with `welcome`, then `ack`/`error` for commands.
- First connected client becomes the controller; additional clients are observers (receive observations only).
- Idle connections close after ~2s by default (configurable in Adapter).
- Runtime config via environment:
  - `TETRIS_AI_TRANSPORT=unix|tcp`
  - `TETRIS_AI_UNIX_PATH=/tmp/tetris-ai.sock`
  - `TETRIS_AI_HOST=127.0.0.1`
  - `TETRIS_AI_PORT=7777`

### Tests (TDD)
1) Add or update a test in Tests/.
2) Implement the change in code.
3) Run swift test.

### Common CLI Commands
- Tests: swift test
- Run: swift run App
- Build (debug): swift build
- Build (release): swift build -c release

## Principles
- **SpriteKit owns the game loop**: use `SKScene.update(_:)` with a fixed timestep accumulator.
- **SwiftUI owns composition**: overlays, HUD, and window behaviors should be SwiftUI-first.
- **Core is deterministic**: all rule changes are test-first and isolated from rendering/input.
- **No per-frame allocations**: reuse nodes, buffers, and arrays to keep frame pacing stable.
- **Assets are bundled**: load audio/textures via `Bundle.module` (SwiftPM) for packaged parity.

## Status
- Architecture alignment is complete; see `docs/progress.md` for the change log.

## Target Architecture
### Loop & Timing
- `TetrisScene` becomes the authoritative loop driver:
  - Maintain `accumulatorMs` + `fixedStepMs` (16ms).
  - Call `Core.GameState.tick` in fixed steps; render once per frame.
- `SceneDriver` becomes a coordinator:
  - Owns Core state and input engine.
  - Exposes a `RenderState` snapshot for the scene to consume.

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

## Alignment Summary (Complete)
- Loop ownership moved to `TetrisScene.update(_:)` with fixed-step timing.
- Render pipeline reuses buffers/nodes and caches textures.
- Input routed through `InputRouter` for keyboard + gamepad consistency.
- Audio uses `AVAudioEngine` with preloaded buffers.
- UI polish includes commands, overlays, focus pause handling, and accessibility coverage.

## Testing Strategy
- Core tests remain the contract for rules and timing.
- UI integration tests cover input routing and overlay state.
- Renderer tests validate mapping logic and resource reuse.

## Risks
- Migrating the loop can change timing; guard with deterministic tests.
- Audio engine changes may affect latency; validate with quick repeat actions.
- Input refactor can cause regressions; maintain exhaustive mapping tests.
