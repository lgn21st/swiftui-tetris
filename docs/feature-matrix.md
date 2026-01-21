# Feature Matrix

Legend:
- Required = must-have for a shippable core experience.
- Optional = nice-to-have polish or extra modes.

## Gameplay Core
| Feature | Required | Notes |
| --- | --- | --- |
| Board size | Yes | 10x20 logical grid. |
| Tetromino set | Yes | I O T S Z J L with SRS rotations. |
| Spawn position | Yes | (x=3, y=0). |
| Rotation system | Yes | SRS kick tables. |
| Ghost piece | Yes | Separate render layer with alpha. |
| Hold | Yes | Once per spawn; swap or store. |
| Next queue | Yes | 1-piece preview. |
| RNG | Yes | 7-bag shuffle. |
| Line clear | Yes | Classic row clear. |
| Line clear pause | Yes | 180 ms freeze; hide active/ghost. |
| Landing flash | Yes | 120 ms flash on lock. |
| Game over | Yes | Spawn blocked. |
| Pause | Yes | Toggle; blocks game input. |
| Pause behavior | Optional | Pausing clears soft drop active state. |
| Restart | Yes | Resets state; keeps started=true. |

## Timing and Movement
| Feature | Required | Notes |
| --- | --- | --- |
| Tick rate | Yes | 16 ms (60 Hz). |
| Drop intervals | Yes | [1000,800,650,500,400,320,250,200,160] ms, floor 120 ms. |
| Soft drop | Yes | Multiplier=10, grace=150 ms. |
| Lock delay | Yes | 450 ms default. |
| Lock reset limit | Yes | 15 resets. |
| DAS/ARR | Yes | DAS 150 ms, ARR 50 ms. |
| Soft drop repeat | Yes | DAS 0, ARR 50 ms. |

## Scoring and Levels
| Feature | Required | Notes |
| --- | --- | --- |
| Classic scoring | Yes | 40/100/300/1200 * (level+1). |
| Soft drop score | Yes | +1 per cell. |
| Hard drop score | Yes | +2 per cell. |
| Leveling | Yes | +1 per 10 lines. |
| Modern ruleset | Optional | T-spins, B2B, combo. |

## Input and UX
| Feature | Required | Notes |
| --- | --- | --- |
| Keyboard mapping | Yes | Left/Right/Down/Up/Space/C. |
| Start | Yes | Enter/Return/Space. |
| Pause | Yes | P. |
| Fullscreen | Optional | Cmd+Ctrl+F. |
| Menu commands | Optional | Minimal menu for restart/pause. |
| Focus loss | Yes | Auto-pause on app inactive. |
| Gamepad | Optional | GameController mapping. |
| Input repeat | Yes | Fixed DAS/ARR/soft drop ARR defaults. |

## UI and Layout
| Feature | Required | Notes |
| --- | --- | --- |
| Base size | Yes | 480x720, cell=24. |
| Layout | Yes | Board + right panel. |
| Scaling | Yes | Uniform scale with min 0.6. |
| Overlays | Yes | Title, pause, game over. |
| Overlay hints | Optional | Title/pause/game over messages. |
| HUD labels | Yes | Score/Level/Lines/Status/Ruleset. |
| HUD details | Optional | Last input, grounded, lock resets. |
| Lock bar | Optional | Visual bar + warning pulse (implemented). |
| Soft drop trail | Optional | Trail between active piece and ghost during soft drop. |
| Active piece highlight | Optional | Subtle highlight pass for active blocks. |
| Board gridlines | Optional | Subtle gridline overlay behind board cells. |
| HUD section typography | Optional | Distinct header sizing for Hold/Next sections. |
| Active drop pulse | Optional | Subtle alpha pulse tied to gravity interval. |
| Ghost tint | Yes | Low alpha. |
| Ghost outline | Optional | Outline stroke on ghost piece (implemented). |
| Accessibility labels | Optional | Overlay labels for title + message. |

## Audio
| Feature | Required | Notes |
| --- | --- | --- |
| Events | Optional | Move/Rotate/SoftDrop/HardDrop/Hold/LineClear/GameOver. |
| Gains | Optional | Per-event gain mapping (defaults). |
| Master volume | Optional | Fixed default 0.7. |

## Diagnostics and Testing
| Feature | Required | Notes |
| --- | --- | --- |
| Rule tests | Yes | Board, actions, timing, scoring. |
| Input repeat tests | Optional | DAS/ARR repeat behavior. |
| Preview cache | Optional | 4x4 mask cache for UI. |

## Engine Architecture
| Feature | Required | Notes |
| --- | --- | --- |
| SpriteKit-driven loop | Optional | Migrate to `SKScene.update(_:)` fixed timestep. |
| Render node reuse | Optional | Pre-allocate nodes; cached textures for piece rendering. |
| Input router | Optional | Unified keyboard/gamepad mapping layer. |
| Audio engine | Optional | AVAudioEngine buffers for low-latency SFX (implemented). |

## Core Checklist
- Board + tetromino rules + SRS rotation.
- Tick/lock/line clear pause with correct timings.
- Classic scoring and level curve.
- Keyboard input + DAS/ARR + soft drop grace.
- Hold + next queue + ghost.
- Title/pause/game over overlays.
- HUD (score/level/lines/hold/next) with preview grids.
