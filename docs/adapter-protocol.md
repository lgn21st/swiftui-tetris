# Adapter Protocol (Summary)

Transport: line-delimited JSON (one message per line).
Schema: `docs/adapter-protocol.schema.json`.

## Handshake
### hello (client -> game)
Fields: `type`, `seq`, `ts`, `client`, `protocol_version`, `formats`, `requested`.

### welcome (game -> client)
Fields: `type`, `seq`, `ts`, `protocol_version`, `game_id`, `capabilities`.

## Commands
### command (client -> game)
- `mode=action`: `actions: ["moveLeft", "rotateCw", ...]`
- `mode=place`: `place: { "x": 3, "rotation": "east", "useHold": false }`

### ack (game -> client)
Fields: `type`, `seq`, `ts`, `status`.

### error (either direction)
Fields: `type`, `seq`, `ts`, `code`, `message`.

## Control
### control (client -> game)
Fields: `type`, `seq`, `ts`, `action: "claim" | "release"`.

## Observations
### observation (game -> client)
Fields: `type`, `seq`, `ts`, `playable`, `board`, `active`, `next`, `hold`, `score`, `level`, `lines`, `timers`.

## Error Codes (current)
- `handshake_required`: command/control before hello
- `protocol_mismatch`: hello version incompatible
- `not_controller`: non-controller sent command/release
- `controller_active`: controller already assigned
- `invalid_command`: missing payload
- `backpressure`: command queue full
