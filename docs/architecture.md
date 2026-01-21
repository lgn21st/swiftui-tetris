# Architecture & Design Review (SwiftUI + SpriteKit)

This document defines the target architecture and refactor plan for a SwiftUI + SpriteKit-native Tetris, without porting constraints. The goal is to maximize responsiveness, maintainability, and testability while using platform-appropriate patterns.

## Principles
- **SpriteKit owns the game loop**: use `SKScene.update(_:)` with a fixed timestep accumulator.
- **SwiftUI owns composition**: overlays, settings, HUD, and window behaviors should be SwiftUI-first.
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
  - Owns Core state, input engine, and settings.
  - Exposes a `RenderState` snapshot for the scene to consume.

### Rendering
- Pre-allocate node grids for board + ghost + effects.
- Use a render buffer to track changed and flash cells without per-frame allocations.
- Update only nodes whose cell state changed, plus flash cells when flash alpha changes.
- Use cached `SKTexture`s for each tetromino color to avoid per-frame drawing.

### Input
- Create a single `InputRouter` that maps keyboard/gamepad to `GameAction`.
- Support SwiftUI `Commands` for menu shortcuts (Pause, Restart, Settings).
- Keep key capture and gamepad handling decoupled from gameplay logic.

### Audio
- Migrate to `AVAudioEngine` with preloaded `AVAudioPCMBuffer`s.
- Mix per-event gain and master volume in a single audio mixer.
- Guarantee low-latency playback for rapid events (move/rotate).

### SwiftUI Composition
- Keep `SpriteView` fixed-size in logical coordinates and scale via SwiftUI.
- Overlay HUD/Settings with `ZStack` and `FocusState`.
- Provide accessibility: reduce motion, keyboard focus order, and legible text sizes.

## Alignment Summary (Complete)
- Loop ownership moved to `TetrisScene.update(_:)` with fixed-step timing.
- Render pipeline reuses buffers/nodes and caches textures.
- Input routed through `InputRouter` for keyboard + gamepad consistency.
- Audio uses `AVAudioEngine` with preloaded buffers.
- UI polish includes commands, overlays, focus pause handling, and accessibility coverage.

## Testing Strategy
- Core tests remain the contract for rules and timing.
- UI integration tests cover input routing, overlay state, and settings.
- Renderer tests validate mapping logic and resource reuse.

## Risks
- Migrating the loop can change timing; guard with deterministic tests.
- Audio engine changes may affect latency; validate with quick repeat actions.
- Input refactor can cause regressions; maintain exhaustive mapping tests.
