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
- `docs/evaluation.md`: comprehensive project evaluation (architecture, visuals, UX, code quality).
- `docs/todo.md`: tech-debt and improvement backlog.
- `docs/adapter-conformance.md`: current protocol version and requirement/test evidence.
- `docs/adapter-implementation-profile.md`: project-local Adapter runtime policy.

## Architecture Expectations
- `Core` owns board, pieces, RNG, scoring, timing, and actions.
- `Runtime` owns the fixed-step accumulator, transaction ordering, and snapshot publication.
- `Headless` owns standalone monotonic scheduling and process lifecycle; it never duplicates Core or Adapter policy.
- `Renderer` renders state from Core; no game logic inside SpriteKit nodes.
- `UI` is platform coordination only: SwiftUI panels/overlays, input, audio, and lifecycle.
- Rendering should reuse preallocated buffers and nodes to minimize per-frame allocations.

## Working Agreements
- Follow strict TDD: every feature, improvement, or refactor must add/adjust tests first.
- Use Swift Testing only; XCTest and Xcode-specific test infrastructure are not supported.
- Keep Swift tools/language mode at 6.2; AppKit/SpriteKit coordinators and their tests are `@MainActor`, while queue-confined I/O uses reviewed Sendable contracts.
- Use `scripts/test`, `scripts/build`, `scripts/run`, and `scripts/server` so CLI builds select the verified SDK and module caches consistently.
- Update Core and tests first; UI changes come after logic is stable.
- If behavior changes, update `docs/rules-spec.md` and `docs/feature-matrix.md`.
- Avoid mixing SpriteKit state mutations with Core rule logic.

## Progress Updates
- Keep `README.md` and `docs/roadmap.md` updated after each phase.
- Last update: Adapter aligned to canonical Tetris AI Adapter Protocol 3.0.0.

## Skills
- Use skill `swiftui-spritekit-tetris-dev` for any SwiftUI/SpriteKit/Core work in this repo.
  - Skill file: `~/.codex/skills/swiftui-spritekit-tetris-dev/SKILL.md`
