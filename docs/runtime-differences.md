# Runtime Differences (CLI vs Packaged)

## Summary
The game is intended to behave the same when launched via `swift run App` and when run as a packaged `.app`.
This document tracks any practical differences, known issues, and verification steps.

## Observed Differences
- None known at this time. (As of 2026-01-21)

## Verification Checklist
- Launch via CLI (`swift run App`) and confirm:
  - Window appears and input works.
  - Audio plays.
  - Assets load from `assets/` via `AssetLocator`.
- Launch packaged app (`dist/SwiftUITeris.app`) and confirm:
  - App icon appears correctly (Finder cache may require a relaunch).
  - Audio plays; assets load from `Contents/Resources/assets/`.
  - Input works (keyboard + gamepad if available).

## Known Causes When Behavior Differs
- Packaged app missing assets: ensure `--assets-path assets` in Packager command.
- Icon not updating: Finder caches icons; restart Finder or re-open window.
- Module cache permissions for release build: use `CLANG_MODULE_CACHE_PATH`.
