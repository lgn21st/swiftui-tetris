#!/usr/bin/env python3
import argparse
import json
import socket
import sys
import time

MAX_FRAME_BYTES = 65_536


def send_line(sock, payload):
    data = json.dumps(payload).encode("utf-8") + b"\n"
    sock.sendall(data)


class JsonLineReader:
    def __init__(self, sock):
        self.sock = sock
        self.buffer = bytearray()

    def read_message(self):
        while True:
            if b"\n" in self.buffer:
                line, remainder = self.buffer.split(b"\n", 1)
                self.buffer = bytearray(remainder)
                if len(line) > MAX_FRAME_BYTES:
                    raise ValueError("adapter frame exceeds 65,536 payload bytes")
                if not line:
                    continue
                message = json.loads(line.decode("utf-8"))
                if not isinstance(message, dict):
                    raise ValueError("adapter message is not a JSON object")
                return message

            chunk = self.sock.recv(4096)
            if not chunk:
                return None
            self.buffer.extend(chunk)
            if len(self.buffer) > MAX_FRAME_BYTES and b"\n" not in self.buffer:
                raise ValueError("adapter frame exceeds 65,536 payload bytes")


def receive_until(reader, predicate):
    while True:
        message = reader.read_message()
        if message is None:
            raise ConnectionError("adapter closed the connection")
        print("<<", json.dumps(message, separators=(",", ":")))
        if predicate(message):
            return message


def main():
    parser = argparse.ArgumentParser(description="Simple tetris-ai TCP client")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7777)
    parser.add_argument("--command", default="")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--claim", action="store_true")
    parser.add_argument("--release", action="store_true")
    args = parser.parse_args()

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((args.host, args.port))
    except Exception as e:
        print(f"Failed to connect to {args.host}:{args.port}: {e}", file=sys.stderr)
        return 2

    hello = {
        "type": "hello",
        "seq": 1,
        "ts": int(time.time() * 1000),
        "client": {"name": "tetris-ai-client", "version": "0.1.0"},
        "protocol_version": "3.0.0",
        "formats": ["json"],
        "requested": {"stream_observations": True, "command_mode": "action"},
    }
    send_line(sock, hello)

    reader = JsonLineReader(sock)
    try:
        receive_until(reader, lambda message: message.get("type") == "welcome")
        seq = 1

        if args.command:
            seq += 1
            actions = [item.strip() for item in args.command.split(",") if item.strip()]
            send_line(sock, {
                "type": "command",
                "seq": seq,
                "ts": int(time.time() * 1000),
                "mode": "action",
                "actions": actions,
            })
            receive_until(
                reader,
                lambda message: message.get("type") in {"ack", "error"}
                and message.get("seq") == seq,
            )

        if args.claim or args.release:
            seq += 1
            send_line(sock, {
                "type": "control",
                "seq": seq,
                "ts": int(time.time() * 1000),
                "action": "claim" if args.claim else "release",
            })
            receive_until(
                reader,
                lambda message: message.get("type") in {"ack", "error"}
                and message.get("seq") == seq,
            )

        while True:
            message = reader.read_message()
            if message is None:
                break
            print("<<", json.dumps(message, separators=(",", ":")))
            if args.once:
                break
        return 0
    except (ConnectionError, OSError, UnicodeError, ValueError) as error:
        print(f"Adapter client failed: {error}", file=sys.stderr)
        return 1
    finally:
        sock.close()


if __name__ == "__main__":
    raise SystemExit(main())
