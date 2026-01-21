# swiftui-teris

macOS-native Tetris built with SwiftUI + SpriteKit. The focus is solid rules, crisp input feel, and clean UI.

## Goals
- SwiftUI for UI/overlays, SpriteKit for board rendering.
- Keep Core deterministic and testable; rendering/input stay decoupled.
- Strict TDD for every feature, improvement, and refactor.
- Favor platform-appropriate patterns (see `docs/architecture.md`).
- Use low-latency audio with preloaded buffers.
- Convention-over-configuration defaults: no Settings UI or persistence; minimal menu actions.

## Run (CLI-first)
- Tests: `swift test`
- Build (debug): `swift build`
- Build (release): `swift build -c release`
- Run app: `swift run App`

## Packaging
- CLI packaging steps live in `docs/cli-packaging.md`.
- Packaged apps should include assets and icon metadata.

## Assets
- Project assets live under `assets/`.
- Audio resolves `assets/sfx` via `UI/AssetLocator` for CLI and packaged runs.
- Keep `assets/README.md` and `assets/sfx/README.md` up to date when assets change.

## Docs
- `docs/architecture.md`: SwiftUI + SpriteKit best-practice alignment.
- `docs/feature-matrix.md`: feature checklist.
- `docs/rules-spec.md`: rules + timing constants.
- `docs/roadmap.md`: scope, goals, and validation checklist.
- `docs/progress.md`: progress log.
- `docs/cli-packaging.md`: packaging steps.
- `docs/codesign-notarize.md`: codesign + notarization steps.
- `docs/release-checklist.md`: pre-release QA checklist.
- `docs/runtime-differences.md`: CLI vs packaged behavior notes.
- `docs/todo.md`: tech-debt and improvement backlog.

## Status
Core and optional features are implemented and covered by tests, including soft drop trail, line-clear shimmer, ghost outline stroke, active-piece highlight textures, lock-bar warning pulse, board gridlines, and an active-piece pulse.
