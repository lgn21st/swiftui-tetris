---
name: swiftui-spritekit-tetris-dev
description: "Build and iterate on the SwiftUI + SpriteKit Tetris port in this repo with strict TDD and CLI-first workflows."
---

# SwiftUI + SpriteKit Tetris Dev

## Scope
Use this skill when:
- Adding or changing Core gameplay rules, timing, scoring, or RNG.
- Editing SpriteKit rendering or SwiftUI overlays/HUD.
- Wiring input handling, audio, or settings.
- Updating tests or docs for TDD compliance.

## Workflow (TDD)
1. Write or update tests first under `Tests/`.
2. Implement Core logic under `Core/` and keep it UI-agnostic.
3. Update Renderer/SpriteKit in `Renderer/` if visuals need changes.
4. Update SwiftUI views and drivers under `UI/`.
5. Run `swift test` and fix failures before moving on.
6. Update docs after each phase: `docs/progress.md`, `docs/porting-plan.md`, plus `README.md` and `AGENTS.md`.

## Architecture Rules
- `Core/` is the single source of truth for rules and timing.
- `Renderer/` only renders `RenderState` and never mutates Core state.
- `UI/` owns input, overlays, settings, and audio integration.
- Avoid SpriteKit state mutations that change gameplay.

## CLI-First Commands
- Tests: `swift test`
- Build (debug): `swift build`
- Build (release): `swift build -c release`
- Run app: `swift run App`
- Package .app: see `docs/cli-packaging.md`

## Asset Handling
- Reference assets from `assets/` and keep `assets/README.md` updated.
- Ensure CLI runs resolve `assets/sfx` via `AssetLocator`.

## Docs to Update
- `docs/rules-spec.md` for any behavior change.
- `docs/feature-matrix.md` for parity updates.
- `docs/porting-plan.md` and `docs/progress.md` after each phase.

## Testing Expectations
- Rule changes require unit tests in `Tests/CoreTests/`.
- Rendering and UI changes require integration tests where feasible in `Tests/UIIntegrationTests/` or `Tests/RendererTests/`.
- Do not merge changes without green `swift test`.
