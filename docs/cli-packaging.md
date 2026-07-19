# CLI Packaging

Use the SwiftPM `Packager` executable to create a local macOS `.app` bundle.

## Build the binary
```sh
scripts/build -c release
```

## Package the app with local assets
```sh
.build/release/Packager \
  --binary-path .build/release/App \
  --output dist/SwiftUITetris.app \
  --bundle-id com.example.swiftui-tetris \
  --name SwiftUITetris \
  --version 0.1.0 \
  --build 1 \
  --icon-path assets/AppIcon.icns \
  --assets-path assets
```

## Notes
- The packager writes `Contents/Info.plist` and copies the binary into `Contents/MacOS/`.
- Generated bundles declare macOS 14.0 as their minimum system version and omit Finder `.DS_Store` metadata from copied assets.
- If `--icon-path` is provided, the `.icns` file is copied into `Contents/Resources/` and referenced in `Info.plist`.
- If `--assets-path` is provided, its contents are copied to `Contents/Resources/assets/`.
- If `dist/SwiftUITetris.app` already exists, delete it before re-running (or use a versioned output path).
- Audio assets are expected under `assets/sfx/` (see `assets/README.md`).
- `scripts/verify` builds and validates a disposable bundle automatically.
- See `docs/local-checklist.md` for CLI and packaged-app checks.
