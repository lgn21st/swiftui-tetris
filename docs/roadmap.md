# Roadmap

## Status

The core feature scope is complete. Current focus is on polish, bug fixes, and technical debt cleanup.

## Tech Debt Cleanup Plan

### Background

The project has achieved feature completeness with broad TDD coverage. A comprehensive code, architecture, documentation, and performance review was repeated on 2026-07-17; details are in `docs/evaluation.md`, with remaining work tracked in `docs/todo.md`.

### Review Summary (2026-07-17)

Resolved T-Spin lock-order scoring, fixed-step catch-up semantics, partial TCP writes, unbounded line framing, hot-path tetromino table reconstruction, per-frame board projection, and path-planner queue complexity. Documentation was reconciled with current focus-loss, queue, transport, asset, and layer behavior.

Aligned the external Adapter through canonical protocol 3.0.0. The current migration adds ordered bounded transition events, authoritative logical steps, correlated applied-state acknowledgements, and intentional v2 rejection while retaining the 2.1 transport, restart, control, and reconnect guarantees. See `docs/adapter-conformance.md`.

### Maintenance

Ongoing: small polish, bug fixes, and keep tests green.
Ongoing: keep Adapter transport compatibility with `tetris-ai` protocol revisions.
Ongoing: restore a complete Xcode/Command Line Tools installation so `swift test` can import the macOS XCTest module on every development machine.

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
- Mute toggle
