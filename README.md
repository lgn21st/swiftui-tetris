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
- Core board logic (bounds, placement, locking, line clears) with tests.
- Drop interval timing logic with tests.
- DAS/ARR repeat logic with tests.
- Placement/collision tests for rotations.
- GameState tick order, lock delay, soft drop grace with tests.
- Ghost projection with tests.
- SRS kick tables and rotation tests.
- Classic scoring and level progression with tests.
- Renderer mapping state and tests.
- RNG 7-bag queue, hold logic, and drop scoring with tests.
- Action mapping, lock reset limit, and pause/game-over guards with tests.
- Preview mask cache, modern rules (combo/B2B), and UI input wiring tests.
- T-spin detection/scoring, render composition, input repeats, and SceneDriver loop.
- Keyboard input capture, overlay state model, and sound event hooks.
- HUD/overlay views and AVAudioPlayer-based audio playback.
- Assets scaffolding, settings UI, and expanded HUD details.
- Asset locator and audio resolution for CLI runs.
- Landing flash rendering with Core + Renderer tests.
- Focus-loss auto-pause with UI integration tests.
- Space-to-start behavior, lock bar warning pulse, and landing flash fade.
- Title overlay start hint (“Press Space or Enter to start”).
- Pause/settings hints, diagnostics overlay toggle, and window defaults.
- Per-event SFX gain mapping with master volume control.
- App activation on launch to surface the window when running from CLI.
- Proportional layout scaling based on window size.
- Layout scaling clamped to minimum 0.6 for parity.
- Per-event SFX sliders in Settings (with overrides).
- Side panel layout with hold/next preview grids and theme polish.
- Settings persistence via UserDefaults.
- Line clear pause hides active/ghost in renderer mapping.
- HUD ruleset label for parity.
- HUD status label for parity.
- CLI packaging smoke test attempted; blocked by sandbox permissions in this environment.
