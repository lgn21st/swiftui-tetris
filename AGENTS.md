# AGENTS

## Project Intent
- Port gpui-tetris to SwiftUI + SpriteKit on macOS.
- Preserve gameplay rules and timing; improve UI only when it does not change core behavior.
- Keep logic testable and UI-agnostic.

## Key Docs
- `docs/rules-spec.md`: authoritative rules/timing constants.
- `docs/feature-matrix.md`: parity checklist.
- `docs/porting-plan.md`: milestones and exit criteria.

## Architecture Expectations
- `Core` owns board, pieces, RNG, scoring, timing, and actions.
- `Renderer` renders state from Core; no game logic inside SpriteKit nodes.
- `UI` is SwiftUI-only: panels, overlays, settings, and window behaviors.

## Working Agreements
- Follow strict TDD: every feature, improvement, or refactor must add/adjust tests first.
- Update Core and tests first; UI changes come after logic is stable.
- If behavior changes, update `docs/rules-spec.md` and `docs/feature-matrix.md`.
- Avoid mixing SpriteKit state mutations with Core rule logic.

## Progress Updates
- Keep `README.md` and `docs/porting-plan.md` updated after each phase.
- Last update: side panel previews + settings persistence + theme polish.

## Skills
- Use skill `swiftui-spritekit-tetris-dev` for any SwiftUI/SpriteKit/Core work in this repo.
  - Skill file: `~/.codex/skills/swiftui-spritekit-tetris-dev/SKILL.md`
- Use skill `gpui-tetris-dev` only when analyzing or referencing gpui source behavior.
