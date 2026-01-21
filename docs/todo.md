# TODO (Tech Debt / Improvement Backlog)

Track areas where we intentionally used a basic implementation and plan to revisit after high-priority work.

## Input / Window / Focus
- Expand non-character key handling (Esc, Tab, function keys, keypad +/-) if needed.
- Validate key repeat behavior in edge cases (held keys across focus changes).
- Confirm gamepad Y button behavior across common controllers.

## Audio / Assets / Packaging
- Verify icon/entitlements flow for signed builds.
- Document any differences between `swift run App` and packaged app behavior.

## UI / UX
- Confirm overlay layering + interaction order across states (Title, Pause, Settings, Game Over).
- Evaluate Settings overlay animation and accessibility (reduced motion, keyboard focus).

## Diagnostics / Tooling
- Validate diagnostics overlay usefulness and key toggles during gameplay.
