# Roadmap

## Status

The core feature scope is complete. Current focus is on polish, bug fixes, and technical debt cleanup.

## Tech Debt Cleanup Plan

### Background

The project has achieved feature completeness with solid TDD coverage. A comprehensive evaluation was performed on 2026-01-22, identifying several minor technical debt items. These do not affect functional correctness but represent opportunities for code quality improvement.

### Identified Technical Debt

| Priority | Item | Description | Estimated Effort |
|----------|------|-------------|------------------|
| **P1** | Magic Numbers Scattering | Hardcoded values (cellSize=24, fontSize=18, zPosition=5) exist in renderer files | 1-2 hours |
| **P1** | GameState Property Exposure | 20+ public properties should be private(set) or moved to snapshot | 1-2 hours |
| **P2** | Test Directory Structure | Tests organized by type (CoreTests/RendererTests) instead of by feature | 2-3 hours |
| **P2** | Code Duplication | Small instances like `formatLastInput` exist in HUD-related files | 1 hour |

### Cleanup Tasks

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

#### P2: Test Directory Restructure

**Current structure**:
```
Tests/
├── CoreTests/      (27 files - organized by type)
├── RendererTests/  (10 files - organized by type)
└── UIIntegrationTests/ (47 files - organized by type)
```

**Proposed structure**:
```
Tests/
├── Core/
│   ├── GameLogic/
│   │   ├── BoardTests.swift
│   │   └── PiecesTests.swift
│   ├── Rules/
│   │   ├── ScoringTests.swift
│   │   ├── RotationTests.swift
│   │   └── SrsKickTests.swift
│   └── Timing/
│       └── TickTests.swift
├── Renderer/
│   ├── Mapping/
│   │   └── RenderMapperTests.swift
│   └── Buffer/
│       └── RenderBufferTests.swift
├── UI/
│   ├── Input/
│   │   └── InputRouterTests.swift
│   └── Integration/
│       └── SceneDriverTests.swift
└── Shared/
    └── GameStateSnapshotTests.swift
```

**Actions**:
1. Create new directory structure
2. Move existing test files to appropriate locations
3. Update package.swift or test discovery configuration if needed

**Verification**:
- Test files organized by feature/domain
- No test file changes required (only directory movement)

#### P2: Code Duplication Elimination

**Known instances**:
- `formatLastInput()` exists in multiple HUD-related files

**Actions**:
1. Search for duplicate functions across UI files
2. Move shared utilities to a shared location (e.g., `UI/Utilities/`)

**Verification**:
- No duplicate function implementations
- Shared utilities used via common import

### Tech Debt Priority Summary

| Priority | Effort | Impact | Recommendation |
|----------|--------|--------|----------------|
| P1 | 1-2 hrs | Low | Do when touching renderer files |
| P1 | 1-2 hrs | Low | Do when Core changes needed |
| P2 | 2-3 hrs | Low | Low priority, aesthetic only |
| P2 | 1 hr | Low | Do when touching HUD files |

### Evaluation Notes

Current project state (as of 2026-01-22):
- **Architecture**: 9.0/10 - Clean three-layer separation, fixed timestep, proper snapshot pattern
- **Visual Design**: 6.5/10 - Clean, focused, T-spin feedback added
- **Gameplay Experience**: 8.0/10 - Professional input handling, DAS/ARR, proper timing
- **Code Quality**: 8.5/10 - Strict TDD, good test coverage, minor technical debt exists

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
