# Rules Spec

This document captures the game rules and timing constants used by this project.

## Core Constants
- Board: width=10, height=20
- Spawn position: (x=3, y=0)
- Next queue size: 1
- Tick step: 16 ms (default GameConfig.tick_ms)
- Base drop ms: 1000 (default GameConfig.base_drop_ms)
- Soft drop multiplier: 10
- Soft drop grace: 150 ms
- Lock delay: 450 ms
- Lock reset limit: 15
- Line clear pause: 180 ms
- Landing flash: 120 ms

## Tetromino Shapes (Offsets)
Rotation order: North, East, South, West.

I:
- N: (0,1) (1,1) (2,1) (3,1)
- E: (2,0) (2,1) (2,2) (2,3)
- S: (0,2) (1,2) (2,2) (3,2)
- W: (1,0) (1,1) (1,2) (1,3)

O:
- All rotations: (1,0) (2,0) (1,1) (2,1)

T:
- N: (1,0) (0,1) (1,1) (2,1)
- E: (1,0) (1,1) (2,1) (1,2)
- S: (0,1) (1,1) (2,1) (1,2)
- W: (1,0) (0,1) (1,1) (1,2)

S:
- N: (1,0) (2,0) (0,1) (1,1)
- E: (1,0) (1,1) (2,1) (2,2)
- S: (1,1) (2,1) (0,2) (1,2)
- W: (0,0) (0,1) (1,1) (1,2)

Z:
- N: (0,0) (1,0) (1,1) (2,1)
- E: (2,0) (1,1) (2,1) (1,2)
- S: (0,1) (1,1) (1,2) (2,2)
- W: (1,0) (0,1) (1,1) (0,2)

J:
- N: (0,0) (0,1) (1,1) (2,1)
- E: (1,0) (2,0) (1,1) (1,2)
- S: (0,1) (1,1) (2,1) (2,2)
- W: (1,0) (1,1) (0,2) (1,2)

L:
- N: (2,0) (0,1) (1,1) (2,1)
- E: (1,0) (1,1) (1,2) (2,2)
- S: (0,1) (1,1) (2,1) (0,2)
- W: (0,0) (1,0) (1,1) (1,2)

## Rotation and Kicks (SRS)
- O: kick table is all zeros.
- I and JLSTZ: use standard SRS kick tables.
- Try kicks in order; first valid placement wins.

## RNG and Queue
- 7-bag shuffle (Fisher-Yates) fills queue.
- LCG RNG (Numerical Recipes constants) for deterministic tests.
- Queue is kept at length >= 1 by refilling bags.

## Actions
GameAction:
- MoveLeft, MoveRight
- SoftDrop, HardDrop
- RotateCw, RotateCcw
- Hold
- Pause, Restart

Rules:
- If game_over, only Restart is accepted.
- If paused, only Pause/Restart is accepted.

### Movement
- Move: attempt dx +/-1; on success update ghost; lock reset may trigger.
- SoftDrop: try move +1; if success score +1. Soft drop activates grace timer.
- HardDrop: move down until blocked; +2 per cell; lock piece immediately.
- Rotate: apply SRS kicks; set last_action_rotate based on success.

### Hold
- Only once per spawn (can_hold flag).
- First hold stores current kind and spawns next.
- Subsequent hold swaps active with held.

## Timing
### Drop Interval
Table by level index:
- 0..8: [1000, 800, 650, 500, 400, 320, 250, 200, 160]
- >=9: 120 ms
Clamp: interval = min(table, base_drop_ms) then max(100 ms).
Soft drop: interval /= soft_drop_multiplier, min 1 ms.

### Tick
If game_over or paused: no updates.
Order per tick:
1) Landing flash timer.
2) Line clear pause timer (if active, stop here).
3) Drop timer update.
4) Apply gravity steps while drop_timer >= interval.
5) Lock timer update.

### Lock Delay + Resets
- If can move down: lock_timer=0 and lock_reset_count=0.
- If grounded: lock_timer += elapsed.
- When lock_timer >= lock_delay: lock piece, reset timers.
- Lock reset on grounded movement/rotation until limit:
  - If grounded and lock_reset_count < lock_reset_limit: lock_timer=0; lock_reset_count++.

### Soft Drop Grace
- When soft drop activated, soft_drop_timeout_ms = soft_drop_grace_ms.
- Timer counts down even if no further soft drop input; when it hits 0, soft_drop_active=false.

## Line Clears and Scoring
### Classic (default)
- Line scores: 1/2/3/4 = 40/100/300/1200
- Score = line_score * (level+1)
- Level increases every 10 lines (level = lines / 10).

### Modern (optional)
- T-spin scoring (full/mini) uses RulesConfig tables.
- B2B applies if T-spin full with lines or Tetris; bonus multiplier 3/2.
- Combo: +combo_base * combo_index (combo starts at 0, increases each consecutive clear).

### T-Spin Detection
- Only if active piece is T and last action was a rotation.
- Check 4 corner cells around T center; if >=3 filled, T-spin.
- If both front corners filled -> Full, else Mini.

## Visual/UX-Driven State
- Started flag gates gameplay until start.
- show_settings pauses game when opened (if not game over).
- Focus loss auto-pauses (if started and not game over).
- Line clear pause hides active/ghost (render rule).
- Landing flash uses last locked cell positions.

## Sound Events (optional)
- Move, Rotate, SoftDrop, HardDrop, Hold, LineClear(n), GameOver.
