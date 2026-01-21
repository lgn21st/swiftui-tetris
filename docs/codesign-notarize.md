# Codesign + Notarize (macOS Release)

Use this checklist to codesign, notarize, and staple the packaged app. These steps require a Developer ID certificate and Apple notarization credentials.

## Prereqs
- Developer ID Application certificate in Keychain.
- Notarytool credentials stored as a keychain profile.
- A packaged `.app` in `dist/` (see `docs/cli-packaging.md`).

## Codesign
```sh
codesign --deep --force --options runtime \
  --entitlements assets/App.entitlements \
  --sign "Developer ID Application: Your Name (TEAMID)" \
  dist/SwiftUITeris.app
```

## Zip for notarization
```sh
ditto -c -k --keepParent dist/SwiftUITeris.app dist/SwiftUITeris.zip
```

## Notarize
```sh
xcrun notarytool submit dist/SwiftUITeris.zip \
  --keychain-profile "AC_NOTARY_PROFILE" \
  --wait
```

## Staple
```sh
xcrun stapler staple dist/SwiftUITeris.app
```

## Verify
```sh
codesign -dv --verbose=4 dist/SwiftUITeris.app
spctl -a -vv dist/SwiftUITeris.app
```

## Notes
- Replace the signing identity and keychain profile with your own values.
- Keep notarization credentials out of the repo.
