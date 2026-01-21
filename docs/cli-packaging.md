# CLI Packaging

This project uses a SwiftPM executable (`Packager`) to create a macOS `.app` bundle from the release binary.

## Build the binary
```sh
swift build -c release
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

## Optional: Icon and Entitlements
```sh
swift run Packager \
  --binary-path .build/release/App \
  --output dist/SwiftUITeris.app \
  --bundle-id com.example.swiftui-teris \
  --name SwiftUITeris \
  --version 0.1.0 \
  --build 1 \
  --icon-path assets/AppIcon.icns \
  --entitlements assets/App.entitlements
```

## Notes
- The packager writes `Contents/Info.plist` and copies the binary into `Contents/MacOS/`.
- If `--icon-path` is provided, the `.icns` file is copied into `Contents/Resources/` and referenced in `Info.plist`.
- If `--entitlements` is provided, the file is copied to `Contents/Entitlements.plist` for later codesign usage.
- If `dist/SwiftUITeris.app` already exists, delete it before re-running (or add a versioned output path).
- Audio assets are expected under `assets/sfx/` (see `assets/README.md`).
