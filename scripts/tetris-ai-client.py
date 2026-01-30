#!/usr/bin/env python3
import argparse
import json
import socket
import sys
import time


def send_line(sock, payload):
    data = json.dumps(payload).encode("utf-8") + b"\n"
    sock.sendall(data)


def read_line(sock):
    buffer = b""
    while True:
        chunk = sock.recv(4096)
        if not chunk:
            return None
        buffer += chunk
        if b"\n" in buffer:
            line, _ = buffer.split(b"\n", 1)
            return line


def main():
    parser = argparse.ArgumentParser(description="Simple tetris-ai client")
    parser.add_argument("--transport", choices=["unix", "tcp"], default="tcp")
    parser.add_argument("--unix-path", default="/tmp/tetris-ai.sock")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7777)
    parser.add_argument("--command", default="")
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--claim", action="store_true")
    parser.add_argument("--release", action="store_true")
    args = parser.parse_args()

    if args.transport == "unix":
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(args.unix_path)
    else:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((args.host, args.port))

    hello = {
        "type": "hello",
        "seq": 1,
        "ts": int(time.time() * 1000),
        "client": {"name": "tetris-ai-client", "version": "0.1.0"},
        "protocol_version": "1.0.0",
        "formats": ["json"],
        "requested": {"stream_observations": True, "command_mode": "action"},
    }
    send_line(sock, hello)

    line = read_line(sock)
    if not line:
        print("No response from server", file=sys.stderr)
        return 1
    print("<<", line.decode("utf-8"))

    if args.command:
        actions = [item.strip() for item in args.command.split(",") if item.strip()]
        command = {
            "type": "command",
            "seq": 2,
            "ts": int(time.time() * 1000),
            "mode": "action",
            "actions": actions,
        }
        send_line(sock, command)
        ack = read_line(sock)
        if ack:
            print("<<", ack.decode("utf-8"))

    if args.claim or args.release:
        control = {
            "type": "control",
            "seq": 3,
            "ts": int(time.time() * 1000),
            "action": "claim" if args.claim else "release",
        }
        send_line(sock, control)
        reply = read_line(sock)
        if reply:
            print("<<", reply.decode("utf-8"))

    while True:
        line = read_line(sock)
        if not line:
            break
        print("<<", line.decode("utf-8"))
        if args.once:
            break
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
