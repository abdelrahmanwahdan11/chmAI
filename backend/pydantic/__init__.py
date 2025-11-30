"""Lightweight Pydantic BaseModel stub for testing without dependency."""
class BaseModel:
    def __init__(self, **data):
        for key, value in data.items():
            setattr(self, key, value)

    class Config:
        orm_mode = False
