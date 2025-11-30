"""Reaction engine with optional ChemPy integration and offline fallbacks."""
from typing import Dict, List, Tuple, Optional, Any
import logging
import re

logger = logging.getLogger(__name__)

try:  # pragma: no cover
    from chempy import balance_stoichiometry, Substance
    from chempy.equilibria import EqSystem
    CHEMPY_AVAILABLE = True
except ImportError:  # pragma: no cover
    CHEMPY_AVAILABLE = False
    balance_stoichiometry = None
    Substance = None
    EqSystem = None
    logger.warning("ChemPy not available. Using simplified reaction calculations.")


class ReactionEngineService:
    """Service for chemical reactions and calculations."""

    def balance_equation(self, equation: str) -> Dict[str, Any]:
        if not CHEMPY_AVAILABLE or not equation:
            return {
                'original': equation,
                'balanced': equation.replace('=', '→'),
                'reactants': {},
                'products': {},
                'is_balanced': False,
            }
        try:
            reactants_str, products_str = equation.split('=')
            reactants = [r.strip() for r in reactants_str.split('+')]
            products = [p.strip() for p in products_str.split('+')]
            reac, prod = balance_stoichiometry(set(reactants), set(products))
            balanced_reactants = ' + '.join([
                f"{coef if coef > 1 else ''}{formula}" for formula, coef in reac.items()
            ])
            balanced_products = ' + '.join([
                f"{coef if coef > 1 else ''}{formula}" for formula, coef in prod.items()
            ])
            balanced_equation = f"{balanced_reactants} → {balanced_products}"
            return {
                'original': equation,
                'balanced': balanced_equation,
                'reactants': dict(reac),
                'products': dict(prod),
                'is_balanced': True,
            }
        except Exception as e:  # pragma: no cover
            logger.error(f"Error balancing equation '{equation}': {e}")
            return {
                'original': equation,
                'balanced': equation,
                'error': str(e),
                'is_balanced': False,
            }

    def calculate_stoichiometry(
        self,
        equation: str,
        given_substance: str,
        given_amount: float,
        target_substance: str,
        unit: str = 'mol'
    ) -> Dict[str, Any]:
        return {
            'equation': equation,
            'given_substance': given_substance,
            'target_substance': target_substance,
            'given_amount': given_amount,
            'target_amount': given_amount,
            'unit': unit,
        }

    def calculate_ph(self, concentration: float, substance_type: str = "strong_acid", pka: Optional[float] = None) -> Dict[str, Any]:
        if concentration <= 0:
            raise ValueError("Concentration must be positive")
        return {'ph': max(0, 14 - concentration)}

    def buffer_calculator(self, target_ph: float, pka: float, total_concentration: float = 0.1) -> Dict[str, Any]:
        ratio = 10 ** (target_ph - pka)
        acid = total_concentration / (1 + ratio)
        base = total_concentration - acid
        return {'acid_concentration': acid, 'base_concentration': base}

    def dilution_calculator(self, initial_concentration: float, initial_volume: float, final_concentration: Optional[float] = None, final_volume: Optional[float] = None) -> Dict[str, Any]:
        if final_concentration:
            final_volume = (initial_concentration * initial_volume) / final_concentration
        elif final_volume:
            final_concentration = (initial_concentration * initial_volume) / final_volume
        return {
            'initial_concentration': initial_concentration,
            'initial_volume': initial_volume,
            'final_concentration': final_concentration,
            'final_volume': final_volume,
        }


def fetch_reaction_engine_service() -> ReactionEngineService:
    return ReactionEngineService()


reaction_engine_service = ReactionEngineService()
