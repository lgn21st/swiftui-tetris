# Codesign + Notarize (macOS Release)

Use this checklist to codesign, notarize, and staple the packaged app. These steps require a Developer ID certificate and Apple notarization credentials.

## Prereqs
- Developer ID Application certificate in Keychain.
- Notarytool credentials stored as a keychain profile.
- A packaged `.app` in `dist/` (see `docs/cli-packaging.md`).

## Preflight
- Verify the packaged app includes assets and icon metadata before signing.
- Confirm `dist/SwiftUITetris.app` launches locally.

## Codesign
```sh
codesign --deep --force --options runtime \
  --entitlements assets/App.entitlements \
  --sign "Developer ID Application: Your Name (TEAMID)" \
  dist/SwiftUITetris.app
```

If you used the Packager `--entitlements` flag, the file is copied to:
`dist/SwiftUITetris.app/Contents/Entitlements.plist`
Use that path for audit/verification after signing.

## Zip for notarization
```sh
ditto -c -k --keepParent dist/SwiftUITetris.app dist/SwiftUITetris.zip
```

## Notarize
```sh
xcrun notarytool submit dist/SwiftUITetris.zip \
  --keychain-profile "AC_NOTARY_PROFILE" \
  --wait
```

## Staple
```sh
xcrun stapler staple dist/SwiftUITetris.app
```

## Verify
```sh
codesign -dv --verbose=4 dist/SwiftUITetris.app
spctl -a -vv dist/SwiftUITetris.app
plutil -p dist/SwiftUITetris.app/Contents/Info.plist | grep CFBundleIconFile
test -f dist/SwiftUITetris.app/Contents/Entitlements.plist
```

## Notes
- Replace the signing identity and keychain profile with your own values.
- Keep notarization credentials out of the repo.
