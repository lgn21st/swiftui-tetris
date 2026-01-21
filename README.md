# swiftui-teris

macOS native Tetris built with SwiftUI + SpriteKit. The priority is solid rules, crisp input feel, and clean UI.

## Goals
- SwiftUI for UI/overlays, SpriteKit for board rendering.
- Keep logic and rendering decoupled; Core must be unit-testable.
- Enforce strict TDD: every feature, improvement, or refactor must be protected by tests.
- Embrace SwiftUI + SpriteKit best practices for timing, rendering, and input.
- Prefer render pipelines that reuse buffers/nodes to avoid per-frame allocations.
- Use AVAudioEngine with preloaded buffers for low-latency overlapping SFX.

## Run (CLI-first)
- Requires macOS + Xcode toolchain (no Xcode UI required).
- Tests: `swift test`
- Build (debug): `swift build`
- Build (release): `swift build -c release`
- Run app: `swift run App`
- Fullscreen toggle: Cmd+Ctrl+F.
- Gamepad: GameController support (dpad + A/B/X/Y + menu/options).

## CLI Packaging
- Package .app (CLI):
  1) `swift build -c release`
  2) `swift run Packager --binary-path .build/release/App --output dist/SwiftUITeris.app --bundle-id com.example.swiftui-teris --name SwiftUITeris --version 0.1.0 --build 1`
  3) Optional: add `--icon-path assets/AppIcon.icns`, `--entitlements assets/App.entitlements`, and `--assets-path assets`
- Details: `docs/cli-packaging.md`
- Packager behavior is covered by `Tests/PackagingTests` (run via `swift test`).

## Assets
- Project assets live under `assets/`.
- Audio playback resolves `assets/sfx` using the CLI working directory via `UI/AssetLocator`.
- Keep `assets/README.md` and `assets/sfx/README.md` updated when assets change.
 - Packaged apps resolve audio from `Contents/Resources/assets/sfx`.

## Planned Structure
- `Core/`: rules, timing, scoring, queue, rotation.
- `Renderer/`: SpriteKit scene and nodes.
- `UI/`: SwiftUI container, panels, overlays.
- `docs/`: rules and plan documents (see below).
- Skills live under `~/.codex/skills` (see `AGENTS.md`).

## Docs
- `docs/feature-matrix.md`: feature checklist.
- `docs/rules-spec.md`: rules and timing constants.
- `docs/roadmap.md`: goals, scope, and validation checklist.
- `docs/architecture.md`: target architecture and refactor plan for SwiftUI + SpriteKit.
- `docs/progress.md`: consolidated progress log.
- `docs/cli-packaging.md`: CLI packaging instructions.
- `docs/codesign-notarize.md`: codesign + notarization steps.
- `docs/release-checklist.md`: pre-release QA checklist.
- `docs/todo.md`: tech-debt and improvement backlog.

## Near-term Plan
See `docs/roadmap.md` for goals and validation.

## Progress
See `docs/progress.md` for the consolidated progress log.

## Current Milestone
Core and optional feature sets are complete.
