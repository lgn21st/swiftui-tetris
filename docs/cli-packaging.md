# CLI Packaging

Use the SwiftPM `Packager` executable to create a macOS `.app` bundle from the release binary.

## Build the binary
```sh
swift build -c release
```

If module cache permissions fail, set an explicit cache path:
```sh
mkdir -p .build/module-cache
CLANG_MODULE_CACHE_PATH="$(pwd)/.build/module-cache" swift build -c release
```

## Package the app
```sh
swift run Packager \
  --binary-path .build/release/App \
  --output dist/SwiftUITeris.app \
  --bundle-id com.example.swiftui-teris \
  --name SwiftUITeris \
  --version 0.1.0 \
  --build 1
```

## Include icon, entitlements, and assets
```sh
swift run Packager \
  --binary-path .build/release/App \
  --output dist/SwiftUITeris.app \
  --bundle-id com.example.swiftui-teris \
  --name SwiftUITeris \
  --version 0.1.0 \
  --build 1 \
  --icon-path assets/AppIcon.icns \
  --entitlements assets/App.entitlements \
  --assets-path assets
```

## Notes
- The packager writes `Contents/Info.plist` and copies the binary into `Contents/MacOS/`.
- If `--icon-path` is provided, the `.icns` file is copied into `Contents/Resources/` and referenced in `Info.plist`.
- If `--entitlements` is provided, the file is copied to `Contents/Entitlements.plist` for later codesign usage.
- If `--assets-path` is provided, its contents are copied to `Contents/Resources/assets/`.
- If `dist/SwiftUITeris.app` already exists, delete it before re-running (or use a versioned output path).
- Audio assets are expected under `assets/sfx/` (see `assets/README.md`).
- See `docs/runtime-differences.md` for CLI vs packaged runtime checks.
- If you see `sandbox-exec: sandbox_apply: Operation not permitted` or SwiftPM cache permission errors, run the packaging steps on a local machine with a writable module cache (see the `CLANG_MODULE_CACHE_PATH` workaround above).
