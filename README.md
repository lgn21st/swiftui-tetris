# swiftui-tetris

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

## External AI (Adapter)
Adapter defaults to unix socket on startup. Override with environment variables:
- `TETRIS_AI_TRANSPORT=unix|tcp` (default: `unix`)
- `TETRIS_AI_UNIX_PATH=/tmp/tetris-ai.sock`
- `TETRIS_AI_HOST=127.0.0.1`
- `TETRIS_AI_PORT=7777`
- `TETRIS_AI_DISABLED=1` (disable adapter entirely)
- `TETRIS_AI_IDLE_TIMEOUT_MS=2000` (set `0` to disable idle disconnect)
- `TETRIS_AI_MAX_PENDING=64` (command queue depth)
- `TETRIS_AI_OBSERVATION_MS=0` (throttle observations; `0` disables)

Example client: `scripts/tetris-ai-client.py` (JSON line protocol).
Note: the first client to send `hello` becomes the controller; additional clients are observers.
Control messages: `control(action=claim|release)` to claim/release control. Non-controllers sending commands receive `not_controller`.
When the controller releases or disconnects, the oldest observer is auto-promoted.
Protocol summary: `docs/adapter-protocol.md`.
JSON schema: `docs/adapter-protocol.schema.json`.

Example (tcp with tuning):
```
TETRIS_AI_TRANSPORT=tcp \
TETRIS_AI_HOST=127.0.0.1 \
TETRIS_AI_PORT=7777 \
TETRIS_AI_IDLE_TIMEOUT_MS=0 \
TETRIS_AI_MAX_PENDING=128 \
TETRIS_AI_OBSERVATION_MS=50 \
swift run App
```

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

## Status
Core and optional features are implemented and covered by tests, including fullscreen + diagnostics overlay, line-clear shimmer, score popups, a T-Spin badge, an ambient loop with ducking, onboarding hints, title hint blink, HUD dividers, footer-aligned Hold/Next previews with larger default-system typography, ghost outline stroke, active-piece highlight textures, lock-bar warning pulse, board gridlines, a group backdrop vignette, and an active-piece pulse. Render mapping now consumes a Core snapshot boundary. External AI control is available via the Adapter layer with unix/tcp transports (disabled unless configured).
