# Feature Matrix (gpui-tetris -> SwiftUI + SpriteKit)

Legend:
- Required = parity with gpui version
- Optional = nice to have
- SwiftUI/SpriteKit notes = adaptation or improvement ideas

## Gameplay Core
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Board size | 10x20 grid | Yes | Use fixed logical grid; render scaling independent of logic. |
| Tetromino set | I O T S Z J L | Yes | Same shapes and rotations (see rules-spec). |
| Spawn position | (x=3, y=0) | Yes | Maintain top-center spawn for parity. |
| Rotation system | SRS kicks for I/J/L/S/T/Z, O no kicks | Yes | Port kicks table verbatim. |
| Ghost piece | Cached landing positions | Yes | SpriteKit: separate node layer with alpha. |
| Hold | Once per spawn; swap or store | Yes | Keep hold gating and can_hold flag. |
| Next queue | 5-piece preview | Yes | Queue filled by 7-bag shuffle. |
| RNG | 7-bag with LCG shuffle | Yes | Use 7-bag; RNG impl can differ if deterministic tests are not required. |
| Line clear | Classic row clear | Yes | Keep clear order from bottom up. |
| Line clear pause | 180 ms freeze | Yes | Freeze gravity and hide active/ghost during pause. |
| Landing flash | 120 ms on lock | Yes | Render flash overlay on last locked cells. |
| Game over | Spawn blocked | Yes | Trigger on spawn if cannot place. |
| Pause | Toggle; blocks game input | Yes | SwiftUI overlay; tick halted. |
| Restart | Resets state | Yes | Keeps started=true after restart. |

## Timing and Movement
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Tick rate | 16 ms (60 Hz) | Yes | Use CADisplayLink or SKView preferredFramesPerSecond. |
| Drop intervals | [1000,800,650,500,400,320,250,200,160] ms, then 120 ms floor | Yes | Same table; clamp to [100, base_drop_ms]. |
| Soft drop | Multiplier=10, grace=150 ms | Yes | Maintain grace after input release. |
| Lock delay | 450 ms default | Yes | Maintain lock timer and reset rules. |
| Lock reset limit | 15 resets | Yes | Reset rules per grounded move/rotate. |
| DAS/ARR | DAS 150 ms, ARR 50 ms | Yes | Implement repeat with timers. |
| Soft drop repeat | DAS 0, ARR 50 ms | Yes | Down repeat should generate SoftDrop actions. |

## Scoring and Levels
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Classic scoring | 40/100/300/1200 * (level+1) | Yes | Default ruleset is Classic. |
| Soft drop score | +1 per cell | Yes | On successful soft drop step. |
| Hard drop score | +2 per cell | Yes | On hard drop before lock. |
| Leveling | +1 per 10 lines | Yes | Level = lines / 10. |
| Modern ruleset | T-spin, B2B, combo | Optional | Keep if easy; default still Classic. |

## Input and UX
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Keyboard mapping | Left/Right/Down/Up/Space/C | Yes | Map to Move/Soft/Rotate/Hard/Hold. |
| Start | Enter/Return; also Space in UI hint | Yes | Accept Enter and Space to start. |
| Pause | P | Yes | Toggle pause. |
| Settings | S | Optional | Keep settings overlay if easy. |
| Mute | M | Optional | Toggle SFX muted. |
| Volume | +/- adjust; 0 reset | Optional | Use 0.1 steps from default 0.7. |
| Fullscreen | Cmd+Ctrl+F | Optional | Key capture maps Cmd+Ctrl+F to NSWindow toggle; window frame persisted. |
| Focus loss | Auto-pause | Yes | On window resign key / app inactive. |
| Gamepad | Xbox mapping via gilrs | Optional | GameController: dpad left/right/down, A/B rotate, X hard drop, Y hold, menu pause, options restart. |

## UI and Layout
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Base size | 480x720, cell=24 | Yes | Keep logical base for scaling. |
| Layout | Board + right panel | Yes | SpriteKit board, SwiftUI side panel. |
| Scaling | Uniform scale with min 0.6 | Yes | Implemented layout scale based on window size. |
| Overlays | Title, pause, settings, game over | Yes | SwiftUI ZStack overlays. |
| HUD labels | Score/Level/Lines/Status/Ruleset | Yes | Bound to GameState; shown in side panel (includes status + ruleset). |
| Lock bar | Visual bar + warning pulse | Optional | Implemented in SwiftUI HUD. |
| Ghost tint | Separate color | Yes | Use low alpha. |

## Audio
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Events | Move/Rotate/SoftDrop/HardDrop/Hold/LineClear/GameOver | Optional | Implement with AVAudioEngine or SKAction. |
| Gains | Per-event gain mapping | Optional | Implemented in UI SoundEventMapper. |
| Master volume | Default 0.7, step 0.1 | Optional | Implemented in settings UI. |

## Diagnostics and Testing
| Feature | gpui baseline | Required | SwiftUI/SpriteKit notes |
| --- | --- | --- | --- |
| Rule tests | Board, actions, timing, scoring | Yes | Mirror tests in Swift unit tests. |
| Input repeat tests | DAS/ARR | Optional | Add logic-level tests for repeat behavior. |
| Preview cache | 4x4 mask | Optional | Precompute masks to simplify UI. |

## Parity Checklist (MVP)
- Board + tetromino rules + SRS rotation.
- Tick/lock/line clear pause with correct timings.
- Classic scoring and level curve.
- Keyboard input + DAS/ARR + soft drop grace.
- Hold + next queue + ghost.
- Title/pause/game over overlays.
- Basic HUD (score/level/lines/hold/next) with preview grids.
