"""Lightweight FastAPI compatibility shims for offline testing.
This stub provides minimal classes and decorators so modules can be
imported without the real FastAPI dependency.
"""
from typing import Callable, Any

class HTTPException(Exception):
    def __init__(self, status_code: int = 500, detail: str | None = None):
        self.status_code = status_code
        self.detail = detail
        super().__init__(detail)

class Depends:
    def __init__(self, dependency: Callable | None = None):
        self.dependency = dependency


def _passthrough_decorator(*args, **kwargs):
    def decorator(func: Callable) -> Callable:
        return func
    return decorator


class APIRouter:
    def __init__(self, prefix: str = "", tags: list[str] | None = None):
        self.prefix = prefix
        self.tags = tags or []

    get = _passthrough_decorator
    post = _passthrough_decorator
    put = _passthrough_decorator
    delete = _passthrough_decorator


class FastAPI:
    def __init__(self, *args: Any, **kwargs: Any):
        self.routes = []

    def include_router(self, router: Any) -> None:  # pragma: no cover - compatibility only
        self.routes.append(router)

    def add_middleware(self, middleware_class: Any, **kwargs: Any) -> None:
        # Middleware registration is a no-op in this stub
        pass
