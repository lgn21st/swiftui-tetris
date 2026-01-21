# swiftui-teris

macOS native Tetris port from gpui-tetris to SwiftUI + SpriteKit. The priority is rules and feel parity, then platform-appropriate improvements.

## Goals
- Match gpui-tetris rules and timing (see `docs/`).
- SwiftUI for UI/overlays, SpriteKit for board rendering.
- Keep logic and rendering decoupled; Core must be unit-testable.
- Enforce strict TDD: every feature, improvement, or refactor must be protected by tests.

## Run
- Requires macOS + Xcode.
- Create and open a SwiftUI App project, then run (details to be added).

## CLI Commands
- Tests: `swift test`
- Build (debug): `swift build`
- Build (release): `swift build -c release`
- Run app: `swift run App`
- Package .app (CLI):\n  1) `swift build -c release`\n  2) `swift run Packager --binary-path .build/release/App --output dist/SwiftUITeris.app --bundle-id com.example.swiftui-teris --name SwiftUITeris --version 0.1.0 --build 1`

## Planned Structure
- `Core/`: rules, timing, scoring, queue, rotation.
- `Renderer/`: SpriteKit scene and nodes.
- `UI/`: SwiftUI container, panels, overlays.
- `docs/`: rules and plan documents (see below).

## Docs
- `docs/feature-matrix.md`: parity checklist.
- `docs/rules-spec.md`: rules and timing constants.
- `docs/porting-plan.md`: milestones and exit criteria.
- `docs/progress.md`: consolidated progress log.
- `docs/cli-packaging.md`: CLI packaging instructions.

## Near-term Plan
- Implement Core module and unit tests.
- Build SpriteKit rendering skeleton.
- Hook up SwiftUI HUD/overlays.

## Progress
- Core board logic (bounds, placement, locking, line clears) with tests.
- Drop interval timing logic with tests.
- DAS/ARR repeat logic with tests.
- Placement/collision tests for rotations.
- GameState tick order, lock delay, soft drop grace with tests.
- Ghost projection with tests.
- SRS kick tables and rotation tests.
- Classic scoring and level progression with tests.
- Renderer mapping state and tests.
