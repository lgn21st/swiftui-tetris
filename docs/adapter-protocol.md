# Adapter Protocol (Summary)

Transport: line-delimited JSON (one message per line).
Schema: `docs/adapter-protocol.schema.json`.

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
- `backpressure`: command queue full
