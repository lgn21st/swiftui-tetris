# Local QA Checklist

The application is local-only. Signing, notarization, distribution identities,
release tags, and publishing workflows are intentionally out of scope.

## Automated Gate

- Run `scripts/verify`.
- It checks architecture boundaries, Python JSONL client behavior, all Swift
  Testing suites, Debug/Release builds, a disposable app bundle, canonical
  Adapter 3.0.0 behavior, and the one-million-step Headless time/RSS budget.

## Interactive App

- `scripts/run` opens the game window.
- Verify keyboard movement, rotation, soft/hard drop, Hold, pause, and restart.
- Verify diagnostics (`D`) and fullscreen (`Cmd+Ctrl+F`).
- Verify losing and regaining focus does not pause the game.
- Listen for move, rotate, drop, line-clear, and game-over audio; confirm ambient
  audio ducks during line clearing.
- If a controller is connected, verify its mapping against
  `docs/gamepad-compat.md`.

## Optional Local Bundle

- Follow `docs/cli-packaging.md` to build `dist/SwiftUITetris.app`.
- Confirm the icon, keyboard input, fullscreen behavior, and audio assets match
  `scripts/run`.
