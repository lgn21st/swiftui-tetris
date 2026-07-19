# Release Checklist (macOS)

Use this checklist before cutting a release build.

## Build + Test
- Run `scripts/verify`; it enforces architecture boundaries, all Swift Testing
  tests, Debug/Release builds, a disposable Release app bundle, canonical
  Adapter verification, and a bounded one-million-step Headless performance/
  memory gate.

## Manual QA (CLI-run)
- `scripts/run` launches a window immediately.
- Keyboard: arrows, rotate, hard drop, hold, pause, restart.
- Audio: confirm move/rotate/line clear events audible; ambient loop plays and ducks on line clears.
- Fullscreen: Cmd+Ctrl+F toggles correctly.
- Diagnostics overlay: toggle on/off (D).
- Window size: fixed to content size (no resize persistence).
- Gamepad: dpad move/drop, A/B rotate, X hard drop, Y hold, menu pause, options restart.
- Gamepad labels: verify Xbox vs Nintendo labeling (see `docs/gamepad-compat.md`).

## Package + QA
- Package with assets:
  ```sh
  swift run Packager \
    --binary-path .build/release/App \
    --output dist/SwiftUITetris.app \
    --bundle-id com.example.swiftui-tetris \
    --name SwiftUITetris \
    --version 0.1.0 \
    --build 1 \
    --icon-path assets/AppIcon.icns \
    --assets-path assets
  ```
- Open `dist/SwiftUITetris.app` and re-run QA checks for audio, input, fullscreen.
- Verify icon in Finder (may require `touch` + `killall Finder`).
- Confirm CLI vs packaged behavior (see `docs/runtime-differences.md`).
- Codesign + notarize for distribution (see `docs/codesign-notarize.md`).

## Notes
- Use unique `--bundle-id` and increment `--version`/`--build` for real releases.
- Keep `README.md`, `docs/architecture.md`, and protocol evidence current.

## Current QA Evidence

- Release bundle launch, keyboard movement/rotation/drop/Hold, pause/resume,
  restart, diagnostics, fullscreen round-trip, and focus-loss recovery pass.
- The live diagnostics overlay reports approximately 59–60 FPS and 16–17 ms
  ticks during this smoke run.
- Audio resources, event routing, mute state, player reuse, and volume behavior
  pass automated tests. Audible output still requires a human listener.
- No USB or Bluetooth game controller is connected, so physical gamepad input
  remains the only unexecuted checklist item.
