# Runtime Differences (CLI vs Packaged)

## Summary
The game should behave the same when launched via `swift run App` and when run as a packaged `.app`.
Use this document to track differences, known issues, and verification steps.

## Observed Differences
- None known at this time. (As of 2026-01-21)

## Verification Checklist
- Launch via CLI (`swift run App`) and confirm:
  - Window appears and input works.
  - Audio plays.
  - Assets load from `assets/` via `AssetLocator`.
- Launch packaged app (`dist/SwiftUITetris.app`) and confirm:
  - App icon appears correctly (Finder cache may require a relaunch).
  - Audio plays; assets load from `Contents/Resources/assets/`.
  - Input works (keyboard + gamepad if available).

## Known Causes When Behavior Differs
- Packaged app missing assets: ensure `--assets-path assets` in the Packager command.
- Icon not updating: Finder caches icons; restart Finder or reopen the window.
- Module cache permissions for release build: set `CLANG_MODULE_CACHE_PATH`.
