# TODO (Tech Debt / Improvement Backlog)

Track areas where we intentionally used a basic implementation and plan to revisit after high-priority work.

## Input / Window / Focus
- Verify focus + input robustness after app deactivation/reactivation (esp. from CLI).
- Expand non-character key handling (Esc, Tab, function keys, keypad +/-) if needed.
- Validate key repeat behavior in edge cases (held keys across focus changes).

## Audio / Assets / Packaging
- Confirm audio path resolution inside packaged `.app` bundle.
- Verify icon/entitlements flow for signed builds.
- Document any differences between `swift run App` and packaged app behavior.

## UI / UX
- Confirm overlay layering + interaction order across states (Title, Pause, Settings, Game Over).
- Evaluate Settings overlay animation and accessibility (reduced motion, keyboard focus).
- Decide whether to keep `HUDView` (currently unused) or remove/replace.

## Diagnostics / Tooling
- Validate diagnostics overlay usefulness and key toggles during gameplay.
- Add optional CLI smoke-test checklist in docs once stable.

