"""Minimal Response stub used for testing."""
class Response:  # pragma: no cover - compatibility only
    def __init__(self, content: bytes | str = b"", media_type: str | None = None):
        self.content = content
        self.media_type = media_type
