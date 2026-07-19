# Release Checklist (macOS)

Use this checklist before cutting a release build.

## Build + Test
- Run `scripts/test` and ensure all tests pass.
- Run `scripts/build -c release` with a clean tree.

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
- Keep `docs/progress.md` and `README.md` updated with release status.
