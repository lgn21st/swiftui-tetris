# Porting Plan (gpui-tetris -> SwiftUI + SpriteKit)

## Goals
- Deliver a macOS native Tetris with feature parity to gpui baseline for core gameplay.
- Use SwiftUI for layout and overlays, SpriteKit for board rendering.
- Allow small UX improvements that fit SwiftUI/SpriteKit strengths without changing core rules.
- Enforce strict TDD: every feature, improvement, or refactor must be protected by tests.

## Scope
### MVP (must-have parity)
- Board 10x20, 7 tetrominoes, SRS rotation.
- Hold, next queue (5), ghost piece.
- Tick/lock/line clear pause timings.
- Classic scoring and leveling.
- Keyboard input with DAS/ARR and soft drop grace.
- Title, pause, game over overlays.
- HUD: score/level/lines/next/hold.

### Optional (post-MVP)
- Modern ruleset (T-spins, B2B, combo).
- Audio with per-event gain and settings UI.
- Gamepad input.
- Lock delay bar + warning pulse.
- Fullscreen toggle, settings overlay.

## Milestones

### M1: Core Rules Engine (logic-only)
**Deliverables**
- `Core` module with board, pieces, rotation, RNG, queue, scoring, and timing.
- Unit tests mirroring gpui behavior.

**Exit Criteria**
- All core tests pass (movement, rotation, lock delay, line clears, scoring, level progression).
- Deterministic tick results for a given seed (if we keep deterministic RNG).

**Notes**
- Match constants in `docs/rules-spec.md`.
- Keep logic UI-agnostic.

## Progress Log
- 2026-01-21: Added Core board logic (bounds, placement, locking, line clears) with TDD tests.
- 2026-01-21: Added drop interval timing logic with TDD tests.
- 2026-01-21: Added DAS/ARR repeat logic with TDD tests.
- 2026-01-21: Added placement/collision tests for rotations.
- 2026-01-21: Added GameState tick order, lock delay, soft drop grace tests and implementation.
- 2026-01-21: Added ghost projection tests and implementation.
- 2026-01-21: Added SRS kick tables and rotation tests.
- 2026-01-21: Added classic scoring and level progression with tests.
- 2026-01-21: Added renderer mapping state and tests.
- 2026-01-21: Added CLI Packager and Packaging module with tests.
- 2026-01-21: Added CLI packager support for icon and entitlements with tests.

### M2: SpriteKit Board Rendering
**Deliverables**
- `SKScene` rendering board, active piece, ghost piece, landing flash.
- Scaled layout based on logical board size.

**Exit Criteria**
- Visual state matches Core state at each tick.
- Line clear pause hides active/ghost while showing locked cells.

**Notes**
- Separate SKNode layers: board, active, ghost, effects, overlays.

### M3: SwiftUI UI Layer + Overlays
**Deliverables**
- SwiftUI container with side panel and overlays.
- Title, pause, game over screens.
- HUD: score/level/lines, hold, next preview.

**Exit Criteria**
- Keyboard input triggers correct actions.
- UI updates are consistent with Core state (no stale HUD).

### M4: Input Timing and Repeat Behavior
**Deliverables**
- DAS/ARR repeat logic for left/right.
- Soft drop repeat and grace window.
- Pause/restart handling and focus loss auto-pause.

**Exit Criteria**
- Repeat behavior matches gpui tests (DAS 150ms, ARR 50ms).
- Soft drop grace behaves correctly without input spam.

### M5: Parity Pass + UX polish
**Deliverables**
- Parity checklist completed.
- Visual polish (colors, overlays, subtle animations).

**Exit Criteria**
- Feature parity for MVP checklist.
- No known regressions vs gpui baseline.

### M6: Optional Features (if desired)
- Audio engine and settings.
- Modern ruleset.
- Gamepad support.
- Fullscreen toggle and window state persistence.

## Validation Checklist
- Movement and rotation: all kicks match SRS tables.
- Gravity and lock delay: behavior consistent with `rules-spec` order.
- Line clear pause: 180ms freeze and flash.
- Scoring: soft drop +1, hard drop +2, classic line scores.
- Level progression: +1 per 10 lines.
- Hold: once per spawn.
- Ghost piece: exact landing projection.

## Testing Policy (TDD)
- Every new feature, improvement, or refactor must start with tests.
- Core logic changes require unit tests that lock in behavior.
- Timing changes require deterministic tick tests using fixed elapsed intervals.
- Input changes require repeat/grace tests for DAS/ARR and soft drop.
- Rendering/UI changes must have at least one state-driven integration test or snapshot-style check where feasible.

## Risks + Mitigations
- **Timing drift**: Use CADisplayLink or SKView FPS to keep consistent tick deltas.
- **Input repeat parity**: Build repeat logic in Core or ViewModel with tests.
- **SpriteKit performance**: Use node reuse and batch updates.
- **State sync**: Keep Core as single source of truth; UI is a projection.

## Work Strategy
- One-time port with incremental milestones.
- Keep docs updated after each milestone.
- Write tests first; changes without tests are not acceptable.

## Dependencies
- SwiftUI (UI + overlays)
- SpriteKit (board rendering)
- XCTest (Core tests)
