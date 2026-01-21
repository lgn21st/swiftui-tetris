# Architecture & Design Review (SwiftUI + SpriteKit)

This document defines the target architecture and refactor plan for a SwiftUI + SpriteKit-native Tetris, without porting constraints. The goal is to maximize responsiveness, maintainability, and testability while using platform-appropriate patterns.

## Principles
- **SpriteKit owns the game loop**: use `SKScene.update(_:)` with a fixed timestep accumulator.
- **SwiftUI owns composition**: overlays, settings, HUD, and window behaviors should be SwiftUI-first.
- **Core is deterministic**: all rule changes are test-first and isolated from rendering/input.
- **No per-frame allocations**: reuse nodes, buffers, and arrays to keep frame pacing stable.
- **Assets are bundled**: load audio/textures via `Bundle.module` (SwiftPM) for packaged parity.

## Gaps in Current Implementation
- Rendering still uses `SKShapeNode` fill/stroke instead of cached textures.
- Input mapping is centralized, but focus/state handling still lives in `SceneDriver`.

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
- Use texture atlas or cached `SKTexture` for each tetromino color if profiling shows fill-rate pressure.

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

## Refactor Plan (TDD)
1) **Loop Migration (Done)**
   - Add tests around loop tick cadence.
   - Move timing from `SceneDriver.Timer` to `TetrisScene.update`.
2) **Render Pipeline (Done)**
   - Add renderer tests to verify node reuse and color mapping.
   - Add render buffer change tracking to avoid full-board updates.
   - Switch to texture caching when node updates are no longer the bottleneck.
3) **Input Router**
   - Add tests for keyboard/gamepad mappings in a unified router.
   - Route all inputs through a single action pipeline.
4) **Audio Engine (Done)**
   - Added tests for pooled playback behavior.
   - Replaced `AVAudioPlayer` with `AVAudioEngine` buffers.
5) **UI Polish Pass**
   - Add snapshot-style UI tests where feasible.
   - Confirm Settings focus, overlay transitions, and reduced motion behavior.

## Testing Strategy
- Core tests remain the contract for rules and timing.
- UI integration tests cover input routing, overlay state, and settings.
- Renderer tests validate mapping logic and resource reuse.

## Risks
- Migrating the loop can change timing; guard with deterministic tests.
- Audio engine changes may affect latency; validate with quick repeat actions.
- Input refactor can cause regressions; maintain exhaustive mapping tests.
