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

## Notes
- The packager writes `Contents/Info.plist` and copies the binary into `Contents/MacOS/`.
- If `dist/SwiftUITeris.app` already exists, delete it before re-running (or add a versioned output path).
