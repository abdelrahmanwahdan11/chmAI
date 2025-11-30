"""
Chemistry Engine - Periodic Table Module
Provides comprehensive periodic table data using Mendeleev library
"""

from mendeleev import element
from mendeleev.fetch import fetch_table
from typing import Dict, List, Optional, Any
import logging

logger = logging.getLogger(__name__)


class PeriodicTableService:
    """Service for periodic table data and element information"""

    def __init__(self):
        # Cache the full periodic table on initialization
        self.periodic_table_df = fetch_table('elements')

    def get_element(self, identifier: str | int) -> Optional[Dict[str, Any]]:
        """
        Get comprehensive information about an element
        
        Args:
            identifier: Element symbol (e.g., 'H'), name (e.g., 'Hydrogen'), or atomic number
            
        Returns:
            Dictionary with all element properties
        """
        try:
            # Get element object
            if isinstance(identifier, int):
                elem = element(identifier)
            else:
                elem = element(identifier)
            
            return {
                # Basic information
                'atomic_number': elem.atomic_number,
                'symbol': elem.symbol,
                'name': elem.name,
                'group': elem.group_id,
                'period': elem.period,
                'block': elem.block,
                
                # Atomic properties
                'atomic_mass': elem.atomic_weight,
                'atomic_radius': elem.atomic_radius,
                'covalent_radius': elem.covalent_radius_pyykko,
                'van_der_waals_radius': elem.vdw_radius,
                
                # Electronic configuration
                'electron_configuration': elem.ec.conf_str() if elem.ec else None,
                'electrons': elem.electrons,
                'electron_affinity': elem.electron_affinity,
                
                # Physical properties
                'density': elem.density,
                'melting_point': elem.melting_point,  # in Kelvin
                'boiling_point': elem.boiling_point,  # in Kelvin
                'specific_heat': elem.specific_heat,
                'thermal_conductivity': elem.thermal_conductivity,
                'electrical_resistivity': elem.electrical_resistivity,
                
                # Chemical properties
                'electronegativity': elem.en_pauling,  # Pauling scale
                'ionization_energies': elem.ionenergies,
                'oxidation_states': elem.oxistates,
                
                # Classification
                'category': self._get_element_category(elem),
                'is_metal': elem.is_metal,
                'is_metalloid': elem.is_metalloid,
                'is_nonmetal': elem.is_nonmetal,
                'is_radioactive': elem.is_radioactive,
                
                # Discovery
                'discovery_year': elem.discoverers,
                'discovery_location': elem.discovery_location,
                
                # Additional data
                'description': elem.description,
                'sources': elem.sources,
                'uses': elem.uses,
            }
            
        except Exception as e:
            logger.error(f"Error fetching element '{identifier}': {e}")
            return None

    def get_periodic_table(self) -> List[Dict[str, Any]]:
        """
        Get the complete periodic table
        
        Returns:
            List of all elements with basic information
        """
        try:
            elements = []
            for i in range(1, 119):  # Elements 1-118
                try:
                    elem = element(i)
                    elements.append({
                        'atomic_number': elem.atomic_number,
                        'symbol': elem.symbol,
                        'name': elem.name,
                        'atomic_mass': elem.atomic_weight,
                        'group': elem.group_id,
                        'period': elem.period,
                        'block': elem.block,
                        'category': self._get_element_category(elem),
                        'color': self._get_category_color(self._get_element_category(elem)),
                    })
                except:
                    continue
            
            return elements
            
        except Exception as e:
            logger.error(f"Error fetching periodic table: {e}")
            return []

    def search_elements(self, criteria: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Search for elements matching specific criteria
        
        Args:
            criteria: Dictionary of search parameters
                - group: Group number
                - period: Period number
                - block: s, p, d, f
                - category: Element category
                - is_metal: True/False
                - min_atomic_mass, max_atomic_mass
                - etc.
        
        Returns:
            List of matching elements
        """
        results = []
        
        for i in range(1, 119):
            try:
                elem = element(i)
                matches = True
                
                # Check each criterion
                if 'group' in criteria and elem.group_id != criteria['group']:
                    matches = False
                if 'period' in criteria and elem.period != criteria['period']:
                    matches = False
                if 'block' in criteria and elem.block != criteria['block']:
                    matches = False
                if 'is_metal' in criteria and elem.is_metal != criteria['is_metal']:
                    matches = False
                    
                if matches:
                    results.append({
                        'atomic_number': elem.atomic_number,
                        'symbol': elem.symbol,
                        'name': elem.name,
                        'atomic_mass': elem.atomic_weight,
                    })
                    
            except:
                continue
        
        return results

    def get_isotopes(self, symbol: str) -> List[Dict[str, Any]]:
        """
        Get isotope information for an element
        
        Args:
            symbol: Element symbol
            
        Returns:
            List of isotopes with their properties
        """
        try:
            elem = element(symbol)
            isotopes = []
            
            # Mendeleev provides isotope data
            if hasattr(elem, 'isotopes'):
                for iso in elem.isotopes:
                    isotopes.append({
                        'mass_number': iso.mass_number,
                        'atomic_mass': iso.atomic_mass,
                        'abundance': iso.abundance,
                        'is_radioactive': iso.is_radioactive,
                        'half_life': getattr(iso, 'half_life', None),
                    })
            
            return isotopes
            
        except Exception as e:
            logger.error(f"Error fetching isotopes for '{symbol}': {e}")
            return []

    def calculate_molar_mass(self, formula: str) -> Optional[float]:
        """
        Calculate molar mass from chemical formula
        
        Args:
            formula: Chemical formula (e.g., 'H2O', 'C6H12O6')
            
        Returns:
            Molar mass in g/mol
        """
        try:
            # Simple parser for chemical formulas
            import re
            
            # Pattern to match element symbol and count
            pattern = r'([A-Z][a-z]?)(\d*)'
            matches = re.findall(pattern, formula)
            
            total_mass = 0.0
            
            for symbol, count in matches:
                if not symbol:
                    continue
                    
                count = int(count) if count else 1
                elem = element(symbol)
                total_mass += elem.atomic_weight * count
            
            return round(total_mass, 4)
            
        except Exception as e:
            logger.error(f"Error calculating molar mass for '{formula}': {e}")
            return None

    # Helper methods
    def _get_element_category(self, elem) -> str:
        """Determine element category for color coding"""
        if elem.is_nonmetal:
            if elem.atomic_number in [1, 6, 7, 8, 15, 16, 34]:
                return 'nonmetal'
            elif elem.atomic_number in [2, 10, 18, 36, 54, 86, 118]:
                return 'noble_gas'
            else:
                return 'halogen'
        elif elem.is_metalloid:
            return 'metalloid'
        elif elem.block == 'f':
            if elem.atomic_number >= 89:
                return 'actinide'
            else:
                return 'lanthanide'
        elif elem.block == 'd':
            return 'transition_metal'
        elif elem.group_id in [1, 2]:
            return 'alkali_alkaline_earth'
        elif hasattr(elem, 'is_post_transition_metal') and elem.is_post_transition_metal:
            return 'post_transition_metal'
        else:
            return 'other_metal'

    def _get_category_color(self, category: str) -> str:
        """Get color code for element category"""
        colors = {
            'nonmetal': '#00FF00',         # Green
            'noble_gas': '#00FFFF',        # Cyan
            'halogen': '#FFFF00',          # Yellow
            'metalloid': '#FFA500',        # Orange
            'actinide': '#FF00FF',         # Magenta
            'lanthanide': '#FF69B4',       # Pink
            'transition_metal': '#FF6347', # Red
            'alkali_alkaline_earth': '#FFD700',  # Gold
            'post_transition_metal': '#C0C0C0',  # Silver
            'other_metal': '#A9A9A9',      # Gray
        }
        return colors.get(category, '#FFFFFF')


# Create singleton instance
periodic_table_service = PeriodicTableService()
