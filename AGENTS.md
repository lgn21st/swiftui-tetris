# AGENTS

## Project Intent
- Build a standalone SwiftUI + SpriteKit Tetris on macOS.
- Preserve gameplay rules and timing; improve UI only when it does not change core behavior.
- Keep logic testable and UI-agnostic.

## Key Docs
- `docs/rules-spec.md`: authoritative rules/timing constants.
- `docs/feature-matrix.md`: feature checklist.
- `docs/roadmap.md`: goals and validation checklist.
- `docs/architecture.md`: SwiftUI + SpriteKit best-practice alignment plan.
- `docs/todo.md`: tech-debt and improvement backlog.

## Architecture Expectations
- `Core` owns board, pieces, RNG, scoring, timing, and actions.
- `Renderer` renders state from Core; no game logic inside SpriteKit nodes.
- `UI` is SwiftUI-only: panels, overlays, and window behaviors.
- Rendering should reuse preallocated buffers and nodes to minimize per-frame allocations.

## Working Agreements
- Follow strict TDD: every feature, improvement, or refactor must add/adjust tests first.
- Update Core and tests first; UI changes come after logic is stable.
- If behavior changes, update `docs/rules-spec.md` and `docs/feature-matrix.md`.
- Avoid mixing SpriteKit state mutations with Core rule logic.

## Progress Updates
- Keep `README.md` and `docs/roadmap.md` updated after each phase.
- Last update: Added ambient loop with line-clear ducking.

## Skills
- Use skill `swiftui-spritekit-tetris-dev` for any SwiftUI/SpriteKit/Core work in this repo.
  - Skill file: `~/.codex/skills/swiftui-spritekit-tetris-dev/SKILL.md`
