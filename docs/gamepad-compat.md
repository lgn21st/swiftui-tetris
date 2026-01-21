# Gamepad Compatibility Notes

This project uses `GameController` with the `extendedGamepad` profile. The mapping assumes the
Xbox-style button labels used by most controllers on macOS.

## Default Mapping
- D-pad left/right/down: move / soft drop
- D-pad up: rotate CW
- A: rotate CW
- B: rotate CCW
- X: hard drop
- Y: hold
- Menu: pause
- Options: restart

## Controller Layout Notes
- Some Nintendo-style controllers swap the physical A/B/X/Y labels relative to Xbox layout.
  If the on-device labels feel “wrong”, the mapping is still correct for the underlying
  GameController button identifiers.
- If a controller reports only a basic gamepad profile (no `extendedGamepad`), it will be ignored.

## Manual Verification
- Test an Xbox-style controller: A/B/X/Y match rotate/drop/hold.
- Test a Nintendo-style controller if available and confirm perceived labeling.
