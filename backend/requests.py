"""Simplified requests stub for offline testing."""
import json


class Response:
    def __init__(self, status_code: int = 200, payload=None, text: str | None = None):
        self.status_code = status_code
        self._payload = payload or {}
        self.text = text or json.dumps(self._payload)

    def json(self):
        return self._payload


class _Exceptions:
    class ConnectionError(Exception):
        pass


exceptions = _Exceptions()

_DEF_STRUCT = {
    "formula": "H2O",
    "atoms": [
        {"symbol": "H", "x": 0.0, "y": 0.0},
        {"symbol": "O", "x": 1.0, "y": 0.0},
    ],
    "bonds": [{"atom1": 0, "atom2": 1, "type": 1}],
    "is_3d": True,
}


def _structure_payload(smiles: str):
    data = dict(_DEF_STRUCT)
    data["smiles"] = smiles
    return data


def get(url: str, *args, **kwargs) -> Response:
    return Response(payload={"status": "ok", "url": url})


def post(url: str, json=None, *args, **kwargs) -> Response:
    if "structure/2d" in url:
        return Response(payload=_structure_payload(json.get("smiles", "")))
    if "structure/3d" in url:
        payload = _structure_payload(json.get("smiles", ""))
        payload["atoms"][0]["z"] = 0.1
        return Response(payload=payload)
    if "structure/descriptors" in url:
        return Response(payload={"basic": {"formula": "C2H6O"}, "physicochemical": {"molecular_weight": 46.07}})
    if "generate_variations" in url:
        variations = [f"Variation {i+1}" for i in range(3)]
        return Response(payload={"variations": variations})
    return Response(payload={"status": "ok", "url": url, "data": json or {}})
