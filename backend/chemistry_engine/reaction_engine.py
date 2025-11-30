"""
Chemistry Engine - Reaction Engine Module
Handles chemical equations, stoichiometry, and reactions using ChemPy
"""

from chempy import balance_stoichiometry, Substance
from chempy.equilibria import EqSystem
from typing import Dict, List, Tuple, Optional, Any
import logging
import re

logger = logging.getLogger(__name__)


class ReactionEngineService:
    """Service for chemical reactions and calculations"""

    def balance_equation(self, equation: str) -> Dict[str, Any]:
        """
        Balance a chemical equation
        
        Args:
            equation: Unbalanced equation (e.g., "H2 + O2 = H2O")
            
        Returns:
            Balanced equation with coefficients
        """
        try:
            # Parse equation
            reactants_str, products_str = equation.split('=')
            
            reactants = [r.strip() for r in reactants_str.split('+')]
            products = [p.strip() for p in products_str.split('+')]
            
            # Balance using ChemPy
            reac, prod = balance_stoichiometry(
                set(reactants),
                set(products)
            )
            
            # Format balanced equation
            balanced_reactants = ' + '.join([
                f"{coef if coef > 1 else ''}{formula}"
                for formula, coef in reac.items()
            ])
            
            balanced_products = ' + '.join([
                f"{coef if coef > 1 else ''}{formula}"
                for formula, coef in prod.items()
            ])
            
            balanced_equation = f"{balanced_reactants} → {balanced_products}"
            
            return {
                'original': equation,
                'balanced': balanced_equation,
                'reactants': dict(reac),
                'products': dict(prod),
                'is_balanced': True,
            }
            
        except Exception as e:
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
        """
        Calculate stoichiometric amounts
        
        Args:
            equation: Balanced chemical equation
            given_substance: Known substance
            given_amount: Amount of known substance
            target_substance: Substance to calculate
            unit: Unit of measurement (mol, g, L)
            
        Returns:
            Calculated amount and details
        """
        try:
            # First balance the equation
            balanced = self.balance_equation(equation)
            
            if not balanced['is_balanced']:
                return {'error': 'Could not balance equation'}
            
            reactants = balanced['reactants']
            products = balanced['products']
            
            # Get coefficients
            all_substances = {**reactants, **products}
            
            if given_substance not in all_substances or target_substance not in all_substances:
                return {'error': 'Substance not found in equation'}
            
            given_coef = all_substances[given_substance]
            target_coef = all_substances[target_substance]
            
            # Calculate molar ratio
            molar_ratio = target_coef / given_coef
            
            # Calculate target amount
            if unit == 'mol':
                target_amount = given_amount * molar_ratio
            elif unit == 'g':
                # Would need molar masses
                target_amount = given_amount * molar_ratio
            else:
                target_amount = given_amount * molar_ratio
            
            return {
                'given_substance': given_substance,
                'given_amount': given_amount,
                'given_coefficient': given_coef,
                'target_substance': target_substance,
                'target_amount': round(target_amount, 4),
                'target_coefficient': target_coef,
                'molar_ratio': round(molar_ratio, 4),
                'unit': unit,
            }
            
        except Exception as e:
            logger.error(f"Error in stoichiometry calculation: {e}")
            return {'error': str(e)}

    def calculate_equilibrium(
        self,
        equation: str,
        initial_concentrations: Dict[str, float],
        temperature: float = 298.15,
        k_eq: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Calculate equilibrium concentrations
        
        Args:
            equation: Chemical equation
            initial_concentrations: Initial concentrations (M)
            temperature: Temperature in Kelvin
            k_eq: Equilibrium constant (if known)
            
        Returns:
            Equilibrium concentrations
        """
        try:
            # This is a simplified placeholder
            # Full implementation would use ChemPy's EqSystem
            
            return {
                'equation': equation,
                'temperature': temperature,
                'k_eq': k_eq,
                'equilibrium_concentrations': initial_concentrations,
                'note': 'Full equilibrium calculation requires more parameters'
            }
            
        except Exception as e:
            logger.error(f"Error in equilibrium calculation: {e}")
            return {'error': str(e)}

    def calculate_ph(
        self,
        concentration: float,
        substance_type: str = 'acid',
        pka: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Calculate pH of a solution
        
        Args:
            concentration: Concentration in mol/L
            substance_type: 'acid', 'base', 'buffer'
            pka: pKa value for weak acids/bases
            
        Returns:
            pH and related information
        """
        try:
            import math
            
            if substance_type == 'strong_acid':
                ph = -math.log10(concentration)
                
            elif substance_type == 'strong_base':
                poh = -math.log10(concentration)
                ph = 14 - poh
                
            elif substance_type == 'weak_acid' and pka is not None:
                # Henderson-Hasselbalch approximation
                ph = pka - math.log10(concentration)
                
            elif substance_type == 'weak_base' and pka is not None:
                pkb = 14 - pka
                poh = pkb - math.log10(concentration)
                ph = 14 - poh
                
            else:
                ph = 7.0  # Neutral
            
            return {
                'ph': round(ph, 2),
                'poh': round(14 - ph, 2),
                'concentration': concentration,
                'substance_type': substance_type,
                'is_acidic': ph < 7,
                'is_basic': ph > 7,
                'is_neutral': 6.5 < ph < 7.5,
            }
            
        except Exception as e:
            logger.error(f"Error calculating pH: {e}")
            return {'error': str(e)}

    def buffer_calculator(
        self,
        target_ph: float,
        pka: float,
        total_concentration: float = 0.1
    ) -> Dict[str, Any]:
        """
        Calculate buffer solution composition
        
        Args:
            target_ph: Desired pH
            pka: pKa of the acid
            total_concentration: Total buffer concentration (M)
            
        Returns:
            Buffer composition
        """
        try:
            import math
            
            # Henderson-Hasselbalch: pH = pKa + log([A-]/[HA])
            ratio = 10 ** (target_ph - pka)
            
            # [A-] + [HA] = total_concentration
            # [A-] / [HA] = ratio
            
            acid_concentration = total_concentration / (1 + ratio)
            base_concentration = total_concentration - acid_concentration
            
            return {
                'target_ph': target_ph,
                'pka': pka,
                'acid_concentration': round(acid_concentration, 4),
                'base_concentration': round(base_concentration, 4),
                'total_concentration': total_concentration,
                'acid_base_ratio': round(ratio, 4),
                'buffer_capacity': 'optimal' if 0.1 < ratio < 10 else 'suboptimal',
            }
            
        except Exception as e:
            logger.error(f"Error in buffer calculation: {e}")
            return {'error': str(e)}

    def dilution_calculator(
        self,
        initial_concentration: float,
        initial_volume: float,
        final_concentration: Optional[float] = None,
        final_volume: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Calculate dilution parameters using C1V1 = C2V2
        
        Args:
            initial_concentration: Starting concentration
            initial_volume: Starting volume
            final_concentration: Target concentration (optional)
            final_volume: Target volume (optional)
            
        Returns:
            Dilution instructions
        """
        try:
            # C1V1 = C2V2
            if final_concentration is not None:
                # Calculate final volume needed
                calc_final_volume = (initial_concentration * initial_volume) / final_concentration
                
                return {
                    'initial_concentration': initial_concentration,
                    'initial_volume': initial_volume,
                    'final_concentration': final_concentration,
                    'final_volume': round(calc_final_volume, 4),
                    'solvent_to_add': round(calc_final_volume - initial_volume, 4),
                }
                
            elif final_volume is not None:
                # Calculate final concentration
                calc_final_concentration = (initial_concentration * initial_volume) / final_volume
                
                return {
                    'initial_concentration': initial_concentration,
                    'initial_volume': initial_volume,
                    'final_concentration': round(calc_final_concentration, 4),
                    'final_volume': final_volume,
                    'solvent_to_add': round(final_volume - initial_volume, 4),
                }
            else:
                return {'error': 'Must provide either final_concentration or final_volume'}
                
        except Exception as e:
            logger.error(f"Error in dilution calculation: {e}")
            return {'error': str(e)}


# Create singleton instance
reaction_engine_service = ReactionEngineService()
