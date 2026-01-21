# Release Checklist (macOS)

Use this checklist before cutting a release build.

## Build + Test
- Run `swift test` and ensure all tests pass.
- Run `swift build -c release` with a clean tree.

## Manual QA (CLI-run)
- `swift run App` launches a window immediately.
- Keyboard: arrows, rotate, hard drop, hold, pause, restart.
- Settings overlay: toggle, adjust volume/mute, input repeat sliders, per-event SFX toggles, close.
- Audio: confirm move/rotate/line clear events audible; verify per-event toggles mute correctly.
- Fullscreen: Cmd+Ctrl+F toggles correctly.
- Window size: fixed to content size (no resize persistence).
- Gamepad: dpad move/drop, A/B rotate, X hard drop, Y hold, menu pause, options restart.
- Gamepad labels: verify Xbox vs Nintendo labeling (see `docs/gamepad-compat.md`).

## Package + QA
- Package with assets:
  ```sh
  swift run Packager \
    --binary-path .build/release/App \
    --output dist/SwiftUITeris.app \
    --bundle-id com.example.swiftui-teris \
    --name SwiftUITeris \
    --version 0.1.0 \
    --build 1 \
    --icon-path assets/AppIcon.icns \
    --assets-path assets
  ```
- Open `dist/SwiftUITeris.app` and re-run QA checks for audio, input, fullscreen.
- Verify icon in Finder (may require `touch` + `killall Finder`).
- Confirm CLI vs packaged behavior (see `docs/runtime-differences.md`).
- Codesign + notarize for distribution (see `docs/codesign-notarize.md`).

## Notes
- Use unique `--bundle-id` and increment `--version`/`--build` for real releases.
- Keep `docs/progress.md` and `README.md` updated with release status.
