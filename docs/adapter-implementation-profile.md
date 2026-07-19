# SwiftUI Tetris Adapter Implementation Profile

Last aligned protocol version: **3.0.0** (2026-07-19)

The normative protocol is maintained by `tui-tetris` in
`protocol/adapter/{VERSION,CHANGELOG.md,SPEC.md,schema.json,profiles/tcp-json-lines.md}`.
This document owns only this project's local runtime choices. It must not be
used to redefine portable wire behavior.

## Startup and endpoint

- Both the SwiftUI app and `TetrisServer` use `AdapterEnvironment` to create the
  same `SocketAdapter`; the app primes it through SceneDriver, while the server
  publishes from `GameRuntime` without UI frameworks.
- TCP JSON Lines is the only transport/format.
- Defaults are `TETRIS_AI_HOST=127.0.0.1` and `TETRIS_AI_PORT=7777`.
- `TETRIS_AI_DISABLED` disables startup when its case-insensitive value is
  `1` or `true`.
- Invalid port values fall back to `7777`; a non-IPv4 host is rejected rather
  than accidentally binding all interfaces. Port `0` remains useful for local
  tests.

## Queues, threads, and scheduling

- `adapter.socket.transport` serializes accept, read, framing, write, and
  connection cleanup. Each connection has an independent bounded outbound
  queue.
- `adapter.socket.state` owns client registration, sequencing, controller
  ownership, observation sequence allocation, and the inbound command queue.
- `GameRuntime` is authoritative: for every fixed step it begins one logical
  transition, drains/applies commands, advances Core, then emits a full snapshot.
- `TetrisServer` uses absolute monotonic 16 ms deadlines and rebases after more
  than 250 ms of lag. `--fast --auto-restart` is a bounded local soak mode and
  requires `TETRIS_AI_DISABLED=1`; it is not portable protocol behavior.
- `AdapterSessionRegistry` is a pure state machine for identity, sequencing,
  controller ownership, observation subscriptions, and disconnect promotion.
- `AdapterCommandExecutor` is the shared, transport-free command application
  path used by both TCP and in-memory adapters.
- `adapter.socket.log` serializes optional JSONL wire logs off the game loop.
  At most 64 best-effort records may be pending; further diagnostic records are
  dropped rather than delaying sockets or gameplay.
- Inbound commands are bounded by `TETRIS_AI_MAX_PENDING` (default `64`). A
  rejection returns `backpressure` with `retry_after_ms` from
  `TETRIS_AI_BACKPRESSURE_RETRY_MS` (default `50`).
- Per-connection queued outbound bytes are bounded by
  `TETRIS_AI_MAX_OUTBOUND_BYTES` (default `262144`). Superseded unsent
  observations are coalesced. A required response that cannot fit closes only
  that connection, so welcome/ack/error is never silently discarded and the
  authoritative loop or unrelated clients do not block.

## Control lifecycle

- A controller/auto hello claims an unowned controller; an observer hello
  never does.
- Any handshaken observer may explicitly claim unowned control.
- Explicit release leaves control unassigned.
- On controller disconnect, auto/controller-eligible clients are promoted by
  lowest `client_id`; explicit observer clients are excluded. Welcome exposes
  this as `auto_promote_on_disconnect=true`, `promotion_order=lowest_client_id`.
- Reconnected sockets receive new client ids and participate as new clients.

## Observation and logging policy

- SceneDriver primes the adapter with its initial snapshot, so a streaming
  hello receives welcome followed immediately by a full observation.
- Core owns the monotonic `logical_step`; an episode restart resets game state
  but does not rewind this connection-lifetime transition counter.
- Core records lock outcomes in causal order for the current transition. The
  wire `events` array retains the first four when a single command batch causes
  more than four lock outcomes, preserving the protocol's hard size bound.
- Successful game-command ack is created only after mutation and carries that
  snapshot's `logical_step` and `state_hash`. Control ack carries only its
  triggering `correlation_seq` because control does not apply game state.
- `TETRIS_AI_OBSERVATION_MS` optionally throttles periodic snapshots; `0` or
  absence means every fixed step. Coalescing/throttling may create valid
  observation-sequence gaps.
- `TETRIS_AI_IDLE_TIMEOUT_MS` defaults to `2000`; `0` disables idle cleanup.
- `TETRIS_AI_LOG_PATH` defaults to `auto`, which creates a timestamped JSONL
  file under `/tmp`; an empty value disables logging.

These capacities, queues, dispatch model, promotion policy, log location, and
startup choices are local to this SwiftUI project and are not copied from the
`tui-tetris` implementation.
