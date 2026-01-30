# Adapter Protocol (Summary)

Transport: line-delimited JSON (one message per line).
Schema: `docs/adapter-protocol.schema.json`.

## Integration Checklist (Game Adapter)
- Socket lifecycle: start listener on app launch; clean up on shutdown; support reconnect without restart.
- Handshake: enforce `hello` first; validate `protocol_version` major; reply with `welcome` including `game_id` and `capabilities`.
- Controller rules: first `hello` becomes controller; reject command/control from observers with `not_controller`; promote next observer on controller disconnect; support `claim`/`release`.
- Framing: newline-delimited JSON; reject empty/partial frames; reply with `invalid_command` on parse/shape errors.
- Sequencing: maintain monotonic `seq` per sender; echo command `seq` in `ack` or `error`.
- Timestamps: `ts` in unix ms; keep monotonic but not necessarily synchronized.
- Observations: send full snapshot (board + active + next + hold + score/level/lines/timers) at fixed step or throttled interval; include `playable` gate.
- Piece kinds: accept lowercase or uppercase in incoming payloads; emit consistent case in outgoing snapshots.
- Action mode: implement `moveLeft`, `moveRight`, `softDrop`, `hardDrop`, `rotateCw`, `rotateCcw`, `hold`, `pause`, `restart`.
- Place mode: validate `x`, `rotation`, `useHold`; apply before tick; reply `invalid_command` on illegal placements.
- Backpressure: if command queue is full, return `backpressure` and continue streaming observations.
- Determinism: apply commands before `GameState.tick` on each fixed step; do not let rendering/UI mutate core.

## Handshake
### hello (client -> game)
Fields: `type`, `seq`, `ts`, `client`, `protocol_version`, `formats`, `requested`.
Example:
```
{"type":"hello","seq":1,"ts":1738291200000,"client":{"name":"tetris-ai","version":"0.1.0"},"protocol_version":"1.0.0","formats":["json"],"requested":{"stream_observations":true,"command_mode":"place"}}
```

### welcome (game -> client)
Fields: `type`, `seq`, `ts`, `protocol_version`, `game_id`, `capabilities`.
Example:
```
{"type":"welcome","seq":1,"ts":1738291200100,"protocol_version":"1.0.0","game_id":"swiftui-spritekit-tetris","capabilities":{"formats":["json"],"command_modes":["action","place"],"features":["hold","next","score","timers"]}}
```

## Commands
### command (client -> game)
- `mode=action`: `actions: ["moveLeft", "rotateCw", ...]`
- `mode=place`: `place: { "x": 3, "rotation": "east", "useHold": false }`
Notes:
- Commands are acknowledged after they are mapped and applied during the adapter poll tick.
Examples:
```
{"type":"command","seq":2,"ts":1738291200200,"mode":"action","actions":["moveLeft","rotateCw","hardDrop"]}
{"type":"command","seq":3,"ts":1738291200300,"mode":"place","place":{"x":3,"rotation":"east","useHold":false}}
```

### ack (game -> client)
Fields: `type`, `seq`, `ts`, `status`.
Example:
```
{"type":"ack","seq":2,"ts":1738291200210,"status":"ok"}
```

### error (either direction)
Fields: `type`, `seq`, `ts`, `code`, `message`.
Example:
```
{"type":"error","seq":3,"ts":1738291200310,"code":"not_controller","message":"Only controller may send commands."}
```

## Control
### control (client -> game)
Fields: `type`, `seq`, `ts`, `action: "claim" | "release"`.
Examples:
```
{"type":"control","seq":10,"ts":1738291200400,"action":"claim"}
{"type":"control","seq":11,"ts":1738291200500,"action":"release"}
```

## Observations
### observation (game -> client)
Fields: `type`, `seq`, `ts`, `playable`, `board`, `active`, `next`, `hold`, `score`, `level`, `lines`, `timers`.
Example:
```
{"type":"observation","seq":20,"ts":1738291200600,"playable":true,"board":{"width":10,"height":20,"cells":[[0,0,0,0,0,0,0,0,0,0]]},"active":{"kind":"t","rotation":"north","x":4,"y":19},"next":"i","hold":null,"score":0,"level":1,"lines":0,"timers":{"tick_ms":1000,"lock_ms":0,"line_clear_ms":0}}
```

## Error Codes (current)
- `handshake_required`: command/control before hello
- `protocol_mismatch`: hello version incompatible
- `not_controller`: non-controller sent command/release
- `controller_active`: controller already assigned
- `invalid_command`: missing payload
- `invalid_place`: place command could not be mapped/applied
- `hold_unavailable`: hold requested when unavailable
- `snapshot_required`: snapshot required for mapping
- `backpressure`: command queue full
