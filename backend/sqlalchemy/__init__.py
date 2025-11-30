"""Minimal SQLAlchemy compatibility layer for testing without dependency."""
class _Type:
    def __init__(self, *args, **kwargs):
        pass

Integer = String = Float = JSON = DateTime = Boolean = _Type

class Column:
    def __init__(self, _type=None, primary_key: bool = False, index: bool = False, unique: bool = False, default=None, ForeignKey=None):
        self.type = _type
        self.primary_key = primary_key
        self.index = index
        self.unique = unique
        self.default = default

    def ilike(self, pattern: str):  # pragma: no cover - stub behavior
        return self

class ForeignKey:
    def __init__(self, target: str):
        self.target = target

def create_engine(*args, **kwargs):  # pragma: no cover - compatibility only
    return None
