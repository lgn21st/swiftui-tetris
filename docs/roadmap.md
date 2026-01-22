# Roadmap

## Status

The core feature scope is complete. Current focus is on polish, bug fixes, and technical debt cleanup.

## Tech Debt Cleanup Plan

### Background

The project has achieved feature completeness with solid TDD coverage. A comprehensive evaluation was performed on 2026-01-22, identifying several minor technical debt items. These do not affect functional correctness but represent opportunities for code quality improvement.

### Review Summary (2026-01-22)

A focused SpriteKit implementation review was completed on 2026-01-22. The core architecture is strong (clean Core/Renderer/UI split, fixed timestep, snapshot rendering), and test coverage is extensive. The review identified a small set of performance and loop-consistency issues that should be addressed before any further UI polish.

**Key findings (most severe first)**:
- Duplicate render path (SceneDriver manually renders, bypassing TetrisScene guards).
- Per-frame allocations in RenderBuffer (violates "no per-frame allocations" goal).
- Pause/render strategy inconsistency (Renderer says "don't render when paused", UI still renders).

**Composite score (10-point scale)**:
- Architecture & separation: **9.0**
- Rules correctness & testability: **9.2**
- Rendering performance & frame pacing: **7.6**
- Input/feel: **8.8**
- UI/UX completeness: **8.5**
- **Overall: 8.6 / 10**

### Identified Technical Debt

| Priority | Item | Description | Estimated Effort |
|----------|------|-------------|------------------|
| **P0** | Render Path De-duplication | SceneDriver renders directly while TetrisScene already renders in update() | 0.5-1 hour |
| **P0** | RenderBuffer Per-frame Allocation | RenderBuffer.update allocates touched/dynamic arrays every frame | 1-2 hours |
| **P1** | Pause Render Policy Consistency | Render guard in TetrisScene conflicts with SceneDriver behavior | 0.5-1 hour |
| **P1** | Magic Numbers Scattering | Hardcoded values (cellSize=24, fontSize=18, zPosition=5) exist in renderer files | 1-2 hours |
| **P1** | GameState Property Exposure | 20+ public properties should be private(set) or moved to snapshot | 1-2 hours |

### Cleanup Tasks

#### P0: Render Path De-duplication (Critical Performance Consistency)

**Scope**: Ensure there is exactly one render path and that render guards are honored.

**Files affected**:
- `Sources/UI/SceneDriver.swift`
- `Sources/Renderer/TetrisScene.swift`

**Actions**:
1. Remove the direct call to `scene.render(state:)` from `SceneDriver.tick`.
2. Keep `latestRenderState` updated; let `TetrisScene.update(_:)` render via `onRender`.

**Verification**:
- No direct rendering from SceneDriver.
- `TetrisScene.shouldRender` and `canRender` guards are respected.

#### P0: RenderBuffer Per-frame Allocation Removal

**Scope**: Eliminate per-frame allocations in the renderer buffer update.

**Files affected**:
- `Sources/Renderer/RenderBuffer.swift`

**Actions**:
1. Add preallocated `touched: [Bool]` and `dynamicIndices: [Int]`.
2. Clear arrays with `removeAll(keepingCapacity: true)` and reset `touched` in-place.
3. Replace `newDynamicIndices` allocations with the preallocated array.

**Verification**:
- No per-frame `Array(repeating:)` or new dynamic index arrays in update().

#### P1: Pause Render Policy Consistency

**Scope**: Ensure pause behavior is consistent across UI and renderer.

**Files affected**:
- `Sources/Renderer/TetrisScene.swift`
- `Sources/UI/SceneDriver.swift`

**Actions**:
1. After P0 render de-duplication, confirm paused state respects `shouldRender`.
2. Optionally avoid `RenderMapper` work when paused if HUD/overlay does not depend on it.

**Verification**:
- Paused state does not render or mutate render buffers unexpectedly.

#### P1: Magic Numbers Consolidation

**Scope**: Centralize all hardcoded constants into `GameConstants` and new `RenderConstants`.

**Files affected**:
- `Sources/Renderer/TetrisScene.swift`
- `Sources/Renderer/TextureCache.swift`
- `Sources/UI/HUDState.swift`
- `Sources/UI/SidePanelView.swift`

**Actions**:
1. Create `RenderConstants.swift` with visual-related constants:
   - `cellSize: CGFloat = 24`
   - `badgeFontSize: CGFloat = 18`
   - `popupFontSize: CGFloat = 16`
   - `gridlineWidth: CGFloat = 1`
   - `zPositions` for various layers

2. Move `gridlineWidth` and `gridlineZ` from `RenderTheme` to `RenderConstants`

3. Replace all hardcoded values with constants in affected files

**Verification**:
- No numeric literals (24, 18, 16, 5, etc.) in renderer/UI files
- All constants are defined in one location

#### P1: GameState Property Access Control

**Scope**: Reduce `GameState` public API surface and enforce snapshot-based access.

**Current state**:
```
GameState has 20+ public properties:
- Core state: board, active, paused, gameOver, score, level, lines
- Timing: dropTimerMs, lockTimerMs, lineClearTimerMs
- Visuals: landingFlashTimerMs, landingFlashBlocks, softDropActive
- Config: config, rng
```

**Actions**:
1. Change timing-related properties to `private(set)`:
   - `dropTimerMs`
   - `lockTimerMs`
   - `lineClearTimerMs`
   - `landingFlashTimerMs`
   - `softDropTimeoutMs`
   - `lockResetCount`

2. Keep as public (required for game loop):
   - `board`
   - `active`
   - `paused`
   - `gameOver`
   - `score`, `level`, `lines`

3. Ensure all external access uses `snapshot()` method

**Verification**:
- `GameState` properties limited to essential public API
- Renderer and UI components use `snapshot()` exclusively

### Optional Cleanup (Defer/When Touching Files)

#### P1: Magic Numbers Consolidation

**Scope**: Centralize all hardcoded constants into `GameConstants` and new `RenderConstants`.

**Files affected**:
- `Sources/Renderer/TetrisScene.swift`
- `Sources/Renderer/TextureCache.swift`
- `Sources/UI/HUDState.swift`
- `Sources/UI/SidePanelView.swift`

**Actions**:
1. Create `RenderConstants.swift` with visual-related constants:
   - `cellSize: CGFloat = 24`
   - `badgeFontSize: CGFloat = 18`
   - `popupFontSize: CGFloat = 16`
   - `gridlineWidth: CGFloat = 1`
   - `zPositions` for various layers

2. Move `gridlineWidth` and `gridlineZ` from `RenderTheme` to `RenderConstants`

3. Replace all hardcoded values with constants in affected files

**Verification**:
- No numeric literals (24, 18, 16, 5, etc.) in renderer/UI files
- All constants are defined in one location

#### P1: GameState Property Access Control

**Scope**: Reduce `GameState` public API surface and enforce snapshot-based access.

**Current state**:
```
GameState has 20+ public properties:
- Core state: board, active, paused, gameOver, score, level, lines
- Timing: dropTimerMs, lockTimerMs, lineClearTimerMs
- Visuals: landingFlashTimerMs, landingFlashBlocks, softDropActive
- Config: config, rng
```

**Actions**:
1. Change timing-related properties to `private(set)`:
   - `dropTimerMs`
   - `lockTimerMs`
   - `lineClearTimerMs`
   - `landingFlashTimerMs`
   - `softDropTimeoutMs`
   - `lockResetCount`

2. Keep as public (required for game loop):
   - `board`
   - `active`
   - `paused`
   - `gameOver`
   - `score`, `level`, `lines`

3. Ensure all external access uses `snapshot()` method

**Verification**:
- `GameState` properties limited to essential public API
- Renderer and UI components use `snapshot()` exclusively

### Tech Debt Priority Summary

| Priority | Effort | Impact | Recommendation |
|----------|--------|--------|----------------|
| P0 | 0.5-2 hrs | Medium | Fix before any further visual polish |
| P1 | 1-2 hrs | Low | Do when touching renderer files |
| P1 | 1-2 hrs | Low | Do when Core changes needed |

### Evaluation Notes

Current project state (as of 2026-01-22):
- **Architecture**: 9.0/10 - Clean three-layer separation, fixed timestep, proper snapshot pattern
- **Visual Design**: 6.5/10 - Clean, focused, T-spin feedback added
- **Gameplay Experience**: 8.0/10 - Professional input handling, DAS/ARR, proper timing
- **Code Quality**: 8.5/10 - Strict TDD, good test coverage, minor technical debt exists
- **Rendering Performance**: 7.6/10 - Duplicate render path + per-frame allocations identified

The identified technical debt does not affect functional correctness. The project is healthy and production-ready.

---

## Original Scope (Completed)

### Core (must-have)
- Board 10x20, 7 tetrominoes, SRS rotation
- Hold, next queue (1), ghost piece
- Tick/lock/line clear pause timings
- Classic scoring and leveling
- Keyboard input with DAS/ARR and soft drop grace
- Title, pause, game over overlays
- HUD with score/level/lines + hold/next preview grids

### Optional (implemented)
- Modern ruleset (T-spins, B2B, combo)
- Audio with per-event gain
- Gamepad input
- Lock delay bar + warning pulse
- Fullscreen toggle, diagnostics overlay
- Board gridlines and HUD typography polish
- Line-clear shimmer overlay
- Onboarding hints on the title overlay
- Title start hint blink
- Backdrop vignette behind board + HUD
- Line-clear score popups
- Ambient loop with line-clear ducking
