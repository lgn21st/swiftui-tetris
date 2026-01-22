# Roadmap

## Status

The core feature scope is complete. Current focus is on polish, bug fixes, and technical debt cleanup.

## Tech Debt Cleanup Plan

### Background

The project has achieved feature completeness with solid TDD coverage. A comprehensive evaluation was performed on 2026-01-22, identifying several minor technical debt items. These do not affect functional correctness but represent opportunities for code quality improvement.

### Review Summary (2026-01-22)

Architecture and tests are strong; no outstanding issues remain from that review.

### Maintenance

Ongoing: small polish, bug fixes, and keep tests green.

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
