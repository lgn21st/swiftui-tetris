import importlib.util
import socket
import threading
import unittest
from pathlib import Path


def load_client_module():
    script = Path(__file__).resolve().parents[1] / "tetris-ai-client.py"
    spec = importlib.util.spec_from_file_location("tetris_ai_client", script)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


client = load_client_module()


class JsonLineReaderTests(unittest.TestCase):
    def test_preserves_second_frame_received_with_first(self):
        reader_socket, writer_socket = socket.socketpair()
        self.addCleanup(reader_socket.close)
        self.addCleanup(writer_socket.close)
        reader = client.JsonLineReader(reader_socket)

        writer_socket.sendall(b'{"type":"welcome","seq":1}\n{"type":"observation","seq":9}\n')

        self.assertEqual(reader.read_message()["type"], "welcome")
        self.assertEqual(reader.read_message()["type"], "observation")

    def test_returns_none_after_clean_eof(self):
        reader_socket, writer_socket = socket.socketpair()
        self.addCleanup(reader_socket.close)
        reader = client.JsonLineReader(reader_socket)
        writer_socket.close()

        self.assertIsNone(reader.read_message())

    def test_rejects_oversized_inbound_frame(self):
        reader_socket, writer_socket = socket.socketpair()
        self.addCleanup(reader_socket.close)
        self.addCleanup(writer_socket.close)
        reader = client.JsonLineReader(reader_socket)
        writer = threading.Thread(target=writer_socket.sendall, args=((b"x" * 65_537) + b"\n",))
        writer.start()

        with self.assertRaisesRegex(ValueError, "65,536"):
            reader.read_message()
        writer.join(timeout=1)


if __name__ == "__main__":
    unittest.main()
