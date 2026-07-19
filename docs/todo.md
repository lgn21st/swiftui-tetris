# Maintenance Backlog

Last reviewed: 2026-07-17

## Verification

- [ ] Finish the native Swift Testing migration and keep `scripts/test` green without Xcode or XCTest.
- [ ] Run the release checklist in `docs/release-checklist.md`, including keyboard, gamepad, audio, focus loss, packaging, and Adapter smoke tests.
- [ ] Capture an Instruments Time Profiler + Allocations baseline for a 10-minute game and an Adapter place-command burst; record results here or in a dated performance report.

## Adapter Hardening

- [x] Bound each connection's queued output and isolate required-response overflow from other clients and the game loop.
- [ ] Consider extracting observation mapping and command mapping from `TetrisAIProtocol.swift` if the protocol gains another major message family.
- [ ] Consider extracting client registry/control ownership from `SocketAdapter.swift` if role semantics expand.

## Maintenance Rules

- Do not split large files solely by line count; extract only around a stable responsibility with tests.
- Keep the sibling `tui-tetris/protocol/adapter` package normative for wire behavior, `docs/adapter-implementation-profile.md` local-only, and `docs/rules-spec.md` normative for gameplay.
- Add or adjust tests before every behavior or performance refactor.
- Keep README, roadmap, progress, evaluation, and this backlog aligned after each review phase.
