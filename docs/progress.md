# Progress Log

## 2026-01-22
- Removed soft drop trail (code + tests) and updated docs.
- Restored landing flash outline with timer‑based alpha.
- Ghost guidance now appears only after a successful move since spawn.
- Line‑clear pause hides active and ghost layers.
- Added render guard to avoid SKView drawable warnings.
- Renderer optimizations: incremental buffer updates, render skip on no changes.
- Prewarmed textures and capped popup nodes; fixed 4‑node active overlay.
- Diagnostics updates throttled (~5Hz).

## 2026-01-21
- HUD typography and layout improvements; hold/next in footer.
- Window defaults and scaling behavior stabilized.
- Audio loop/ducking and diagnostics overlay refined.
