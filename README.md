# swiftui-teris

macOS native Tetris port from gpui-tetris to SwiftUI + SpriteKit. The priority is rules and feel parity, then platform-appropriate improvements.

## Goals
- Match gpui-tetris rules and timing (see `docs/`).
- SwiftUI for UI/overlays, SpriteKit for board rendering.
- Keep logic and rendering decoupled; Core must be unit-testable.
- Enforce strict TDD: every feature, improvement, or refactor must be protected by tests.

## Run (CLI-first)
- Requires macOS + Xcode toolchain (no Xcode UI required).
- Tests: `swift test`
- Build (debug): `swift build`
- Build (release): `swift build -c release`
- Run app: `swift run App`

## CLI Packaging
- Package .app (CLI):
  1) `swift build -c release`
  2) `swift run Packager --binary-path .build/release/App --output dist/SwiftUITeris.app --bundle-id com.example.swiftui-teris --name SwiftUITeris --version 0.1.0 --build 1`
  3) Optional: add `--icon-path assets/AppIcon.icns` and `--entitlements assets/App.entitlements`
- Details: `docs/cli-packaging.md`

## Assets
- Project assets live under `assets/`.
- Audio playback resolves `assets/sfx` using the CLI working directory via `UI/AssetLocator`.
- Keep `assets/README.md` and `assets/sfx/README.md` updated when assets change.

## Planned Structure
- `Core/`: rules, timing, scoring, queue, rotation.
- `Renderer/`: SpriteKit scene and nodes.
- `UI/`: SwiftUI container, panels, overlays.
- `docs/`: rules and plan documents (see below).
- Skills live under `~/.codex/skills` (see `AGENTS.md`).

## Docs
- `docs/feature-matrix.md`: parity checklist.
- `docs/rules-spec.md`: rules and timing constants.
- `docs/porting-plan.md`: milestones and exit criteria.
- `docs/progress.md`: consolidated progress log.
- `docs/cli-packaging.md`: CLI packaging instructions.

## Near-term Plan
- Complete M5 parity checklist and verify gpui timing/feel.
- Perform UI polish pass (layout, typography, colors).
- Run CLI packaging smoke test and document any gaps.

## Progress
See `docs/progress.md` for the consolidated progress log.
