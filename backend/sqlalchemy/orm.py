"""Stub implementations of SQLAlchemy ORM helpers."""
class Session:
    def __init__(self, *args, **kwargs):
        pass


def sessionmaker(*args, **kwargs):  # pragma: no cover - compatibility only
    class _SessionLocal:
        def __call__(self, *args, **kwargs):
            return Session()
    return _SessionLocal()


def relationship(*args, **kwargs):  # pragma: no cover - compatibility only
    return None
