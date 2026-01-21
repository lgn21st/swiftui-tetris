# Roadmap

## Goals
- Deliver a polished macOS-native Tetris built with SwiftUI + SpriteKit.
- Keep rules, timing, and input feel consistent and testable.
- Enforce strict TDD: every feature, improvement, or refactor must be protected by tests.
- Align architecture with SwiftUI + SpriteKit best practices (see `docs/architecture.md`).

## Scope
### Core (must-have)
- Board 10x20, 7 tetrominoes, SRS rotation.
- Hold, next queue (1), ghost piece.
- Tick/lock/line clear pause timings.
- Classic scoring and leveling.
- Keyboard input with DAS/ARR and soft drop grace.
- Title, pause, game over overlays.
- HUD with score/level/lines + hold/next preview grids.

### Optional (nice-to-have)
- Modern ruleset (T-spins, B2B, combo).
- Audio with per-event gain and settings UI.
- Gamepad input.
- Lock delay bar + warning pulse (implemented).
- Fullscreen toggle, settings overlay, diagnostics overlay.

## Current Status (Snapshot)
- Core rules, timing, scoring, RNG, hold/queue: complete with tests.
- Input repeat + pause/focus handling: complete with tests.
- SpriteKit board rendering + landing flash + texture cache: complete with tests.
- HUD/overlays and settings: complete with tests.
- Audio: per-event gain + settings + persistence; AVAudioEngine buffers for overlapping SFX.
- Window defaults + scaling: implemented; content stays centered on resize.
- SwiftUI menu commands: start/restart/pause/settings actions wired.
- Settings: configurable DAS/ARR/soft drop ARR + per-event SFX toggles.
- Soft drop trail + active piece highlight for board polish.
- Lock bar warning pulse in HUD.

## Best-Practice Alignment
- Architecture alignment work is complete; details live in `docs/architecture.md`.
- Progress tracking for the alignment work is in `docs/progress.md`.

## Validation Checklist
- Movement and rotation: SRS tables verified by tests.
- Gravity and lock delay: behavior consistent with `docs/rules-spec.md`.
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
- Rendering/UI changes must have at least one state-driven integration test.

## Work Strategy
- CLI-first workflow (no Xcode UI required).
- Keep docs updated after each phase.
- No behavior changes without updating `docs/rules-spec.md` and tests.

## Dependencies
- SwiftUI (UI + overlays)
- SpriteKit (board rendering)
- XCTest (tests)
