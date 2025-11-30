"""Self-contained periodic table utilities without external dependencies."""
from typing import Dict, List, Optional, Any
import logging

logger = logging.getLogger(__name__)

# Minimal subset of periodic table data needed for filtering tests
_ELEMENT_DATA = [
    {"atomic_number": 1, "symbol": "H", "name": "Hydrogen", "group": 1, "period": 1, "block": "s", "is_metal": False},
    {"atomic_number": 3, "symbol": "Li", "name": "Lithium", "group": 1, "period": 2, "block": "s", "is_metal": True},
    {"atomic_number": 4, "symbol": "Be", "name": "Beryllium", "group": 2, "period": 2, "block": "s", "is_metal": True},
    {"atomic_number": 6, "symbol": "C", "name": "Carbon", "group": 14, "period": 2, "block": "p", "is_metal": False},
    {"atomic_number": 7, "symbol": "N", "name": "Nitrogen", "group": 15, "period": 2, "block": "p", "is_metal": False},
    {"atomic_number": 8, "symbol": "O", "name": "Oxygen", "group": 16, "period": 2, "block": "p", "is_metal": False},
    {"atomic_number": 9, "symbol": "F", "name": "Fluorine", "group": 17, "period": 2, "block": "p", "is_metal": False},
    {"atomic_number": 10, "symbol": "Ne", "name": "Neon", "group": 18, "period": 2, "block": "p", "is_metal": False},
    {"atomic_number": 11, "symbol": "Na", "name": "Sodium", "group": 1, "period": 3, "block": "s", "is_metal": True},
    {"atomic_number": 17, "symbol": "Cl", "name": "Chlorine", "group": 17, "period": 3, "block": "p", "is_metal": False},
]


class PeriodicTableService:
    """Small, in-memory periodic table service for testing."""

    def get_element(self, identifier: str | int) -> Optional[Dict[str, Any]]:
        for element in _ELEMENT_DATA:
            if identifier == element["symbol"] or identifier == element["atomic_number"]:
                return element
        logger.warning("Element %s not found", identifier)
        return None

    def get_periodic_table(self) -> List[Dict[str, Any]]:
        return list(_ELEMENT_DATA)

    def search_elements(self, criteria: Dict[str, Any]) -> List[Dict[str, Any]]:
        results = []
        for element in _ELEMENT_DATA:
            matches = True
            if "group" in criteria and element["group"] != criteria["group"]:
                matches = False
            if "period" in criteria and element["period"] != criteria["period"]:
                matches = False
            if "block" in criteria and element["block"] != criteria["block"]:
                matches = False
            if "is_metal" in criteria and element["is_metal"] != criteria["is_metal"]:
                matches = False
            if matches:
                results.append({
                    "atomic_number": element["atomic_number"],
                    "symbol": element["symbol"],
                    "name": element["name"],
                    "atomic_mass": None,
                })
        return results

    def get_isotopes(self, symbol: str) -> List[Dict[str, Any]]:
        # Simple placeholder data for testing
        element = self.get_element(symbol)
        if not element:
            return []
        return [
            {"mass_number": element["atomic_number"], "atomic_mass": element["atomic_number"] + 0.0, "abundance": 100.0, "is_radioactive": False}
        ]

    def calculate_molar_mass(self, formula: str) -> Optional[float]:
        # Simple molar mass calculator using atomic_number as proxy weight
        if not formula:
            return None
        mass = 0.0
        for char in formula:
            element = next((e for e in _ELEMENT_DATA if e["symbol"].startswith(char)), None)
            if not element:
                return None
            mass += float(element["atomic_number"])
        return mass


def fetch_periodic_table_service() -> PeriodicTableService:
    return PeriodicTableService()


periodic_table_service = PeriodicTableService()
