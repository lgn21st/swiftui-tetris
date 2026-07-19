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
- Requirements: macOS 14+, Swift 6.2 Command Line Tools. The package builds in Swift 6 language mode; Xcode is not required.
- Tests: `scripts/test`
- Complete verification gate: `scripts/verify`
- Build (debug): `scripts/build`
- Build (release): `scripts/build -c release`
- Run app: `scripts/run`
- Run headless protocol server: `scripts/server`

## External AI (Adapter)
Adapter implements Tetris AI Adapter Protocol `3.0.0` over TCP JSON Lines. Environment variables:
- `TETRIS_AI_HOST=127.0.0.1`
- `TETRIS_AI_PORT=7777`
- `TETRIS_AI_DISABLED=1` or `true` (disable adapter entirely)
- `TETRIS_AI_IDLE_TIMEOUT_MS=2000` (set `0` to disable idle disconnect)
- `TETRIS_AI_MAX_PENDING=64` (command queue depth)
- `TETRIS_AI_MAX_OUTBOUND_BYTES=262144` (per-client queued output bound)
- `TETRIS_AI_BACKPRESSURE_RETRY_MS=50` (retry hint)
- `TETRIS_AI_OBSERVATION_MS=0` (throttle observations; `0` disables)
- `TETRIS_AI_LOG_PATH=/tmp/tetris-ai-adapter.jsonl` (default `auto`)

Example client: `scripts/tetris-ai-client.py` (JSON line protocol).
Normative protocol: the sibling `tui-tetris/protocol/adapter` package. Local
runtime choices and alignment evidence live in
`docs/adapter-implementation-profile.md` and `docs/adapter-conformance.md`.

Example (tuning):
```
TETRIS_AI_IDLE_TIMEOUT_MS=0 \
TETRIS_AI_MAX_PENDING=128 \
TETRIS_AI_OBSERVATION_MS=50 \
swift run App
```

For protocol clients and unattended validation, prefer the UI-free server:
```
scripts/server --seed 42
TETRIS_AI_DISABLED=1 scripts/server --fast --auto-restart --steps 1000000
```
`--fast` is deliberately rejected while Adapter networking is enabled; it is
only a bounded local soak/performance mode.

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
- `docs/cli-packaging.md`: packaging steps.
- `docs/codesign-notarize.md`: codesign + notarization steps.
- `docs/release-checklist.md`: pre-release QA checklist.
- `docs/runtime-differences.md`: CLI vs packaged behavior notes.
- `docs/adapter-implementation-profile.md`: local Adapter queues, scheduling, logging, and startup.
- `docs/adapter-conformance.md`: protocol 3.0.0 requirement/evidence matrix.

## Status
Core and optional features are implemented behind a deterministic headless Runtime with private mutable state and immutable snapshot consumers. `TetrisServer` runs that runtime and Adapter without SwiftUI, SpriteKit, AppKit, or audio. `scripts/verify` is the Xcode-independent release gate for architecture, tests, builds, protocol conformance, and headless soak performance. External AI control is available through the localhost TCP Adapter (disable with `TETRIS_AI_DISABLED=1`). Current architecture and residual risks are recorded in `docs/architecture.md`.
