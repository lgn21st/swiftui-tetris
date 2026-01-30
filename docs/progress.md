# Progress Log

## 2026-01-30
- Added Adapter layer for external AI control with unix/tcp transports and JSON line framing.
- Wired Adapter into SceneDriver (poll before tick, emit after snapshot).
- Added protocol codec and mapping tests for command/observation flow.
- Added handshake/ack/error flow, idle timeout, and example client script for adapter testing.
- Added controller/observer support and stricter place command path validation.

## 2026-01-22
- Removed soft drop trail (code + tests) and updated docs.
- Restored landing flash outline with timer‑based alpha.
- Ghost guidance now appears only after a successful move since spawn.
- Line‑clear pause hides active and ghost layers.
- Added render guard to avoid SKView drawable warnings.
- Renderer optimizations: incremental buffer updates, render skip on no changes.
- Prewarmed textures and capped popup nodes; fixed 4‑node active overlay.
- Diagnostics updates throttled (~5Hz).
- Folded the beginner guide into `docs/architecture.md` and merged todo into roadmap.

## 2026-01-21
- HUD typography and layout improvements; hold/next in footer.
- Window defaults and scaling behavior stabilized.
- Audio loop/ducking and diagnostics overlay refined.
