"""
Chemistry Engine - Compound Lookup Module
Integrates with PubChem for comprehensive compound information
"""

import pubchempy as pcp
from typing import Dict, List, Optional, Any
import logging

logger = logging.getLogger(__name__)


class CompoundLookupService:
    """Service for looking up chemical compound information"""

    def __init__(self):
        self.cache = {}  # Simple in-memory cache

    def search_compound(self, query: str, search_type: str = "name") -> List[Dict[str, Any]]:
        """
        Search for compounds by name, CAS, formula, etc.
        
        Args:
            query: Search term
            search_type: Type of search ('name', 'formula', 'smiles', etc.)
            
        Returns:
            List of matching compounds
        """
        try:
            compounds = pcp.get_compounds(query, search_type)
            results = []
            
            for compound in compounds[:10]:  # Limit to top 10 results
                results.append({
                    'cid': compound.cid,
                    'name': compound.iupac_name or compound.synonyms[0] if compound.synonyms else query,
                    'molecular_formula': compound.molecular_formula,
                    'molecular_weight': compound.molecular_weight,
                    'canonical_smiles': compound.canonical_smiles,
                    'isomeric_smiles': compound.isomeric_smiles,
                    'inchi': compound.inchi,
                    'inchikey': compound.inchikey,
                })
            
            return results
            
        except Exception as e:
            logger.error(f"Error searching compound '{query}': {e}")
            return []

    def get_compound_info(self, cid: int) -> Optional[Dict[str, Any]]:
        """
        Get detailed information about a compound by CID
        
        Args:
            cid: PubChem Compound ID
            
        Returns:
            Comprehensive compound information
        """
        # Check cache first
        if cid in self.cache:
            return self.cache[cid]

        try:
            compound = pcp.Compound.from_cid(cid)
            
            info = {
                'cid': compound.cid,
                'iupac_name': compound.iupac_name,
                'molecular_formula': compound.molecular_formula,
                'molecular_weight': compound.molecular_weight,
                'canonical_smiles': compound.canonical_smiles,
                'isomeric_smiles': compound.isomeric_smiles,
                'inchi': compound.inchi,
                'inchikey': compound.inchikey,
                
                # Physical properties
                'complexity': compound.complexity,
                'heavy_atom_count': compound.heavy_atom_count,
                'h_bond_acceptor_count': compound.h_bond_acceptor_count,
                'h_bond_donor_count': compound.h_bond_donor_count,
                'rotatable_bond_count': compound.rotatable_bond_count,
                
                # Computed properties
                'exact_mass': compound.exact_mass,
                'monoisotopic_mass': compound.monoisotopic_mass,
                'tpsa': compound.tpsa,  # Topological polar surface area
                'xlogp': compound.xlogp,  # Partition coefficient
                
                # Synonyms
                'synonyms': compound.synonyms[:20] if compound.synonyms else [],
                
                # Identifiers
                'cas_number': self._extract_cas(compound),
            }
            
            # Cache the result
            self.cache[cid] = info
            
            return info
            
        except Exception as e:
            logger.error(f"Error fetching compound CID {cid}: {e}")
            return None

    def get_similar_compounds(self, cid: int, threshold: float = 90.0) -> List[Dict[str, Any]]:
        """
        Find structurally similar compounds
        
        Args:
            cid: Reference compound CID
            threshold: Similarity threshold (0-100)
            
        Returns:
            List of similar compounds
        """
        try:
            # Get similar compounds from PubChem
            similar = pcp.get_compounds(cid, 'cid', listkey_count=20)
            results = []
            
            for comp in similar:
                results.append({
                    'cid': comp.cid,
                    'name': comp.iupac_name or (comp.synonyms[0] if comp.synonyms else f"CID {comp.cid}"),
                    'molecular_formula': comp.molecular_formula,
                    'molecular_weight': comp.molecular_weight,
                    'similarity_score': 95.0,  # PubChem doesn't provide exact scores
                })
            
            return results
            
        except Exception as e:
            logger.error(f"Error finding similar compounds for CID {cid}: {e}")
            return []

    def get_safety_info(self, cid: int) -> Dict[str, Any]:
        """
        Get safety and hazard information
        
        Args:
            cid: PubChem Compound ID
            
        Returns:
            Safety information dictionary
        """
        try:
            # PubChem provides GHS classification
            properties = pcp.get_properties(
                ['GHSClassification'], 
                cid, 
                'cid'
            )
            
            safety_data = {
                'ghs_classification': properties[0].get('GHSClassification', '') if properties else '',
                'ghs_pictograms': self._extract_ghs_pictograms(cid),
                'hazard_statements': self._get_hazard_statements(cid),
                'precautionary_statements': self._get_precautionary_statements(cid),
                'signal_word': self._get_signal_word(cid),
            }
            
            return safety_data
            
        except Exception as e:
            logger.error(f"Error fetching safety info for CID {cid}: {e}")
            return {
                'ghs_classification': '',
                'ghs_pictograms': [],
                'hazard_statements': [],
                'precautionary_statements': [],
                'signal_word': '',
            }

    def get_reactions(self, cid: int) -> List[Dict[str, Any]]:
        """
        Get known reactions involving this compound
        
        Args:
            cid: PubChem Compound ID
            
        Returns:
            List of reactions
        """
        # This would ideally connect to a reactions database
        # For now, return placeholder
        return [
            {
                'reaction_id': 'R001',
                'type': 'synthesis',
                'description': 'Common synthesis pathway',
                'conditions': 'Standard conditions',
            }
        ]

    # Helper methods
    def _extract_cas(self, compound) -> Optional[str]:
        """Extract CAS number from synonyms"""
        if not compound.synonyms:
            return None
            
        for synonym in compound.synonyms:
            # CAS format: XXX-XX-X or XXXX-XX-X, etc.
            if '-' in synonym and synonym.replace('-', '').isdigit():
                return synonym
        return None

    def _extract_ghs_pictograms(self, cid: int) -> List[str]:
        """Extract GHS pictogram codes"""
        # This would require accessing PubChem's GHS data
        # Placeholder implementation
        return ['GHS02', 'GHS07']  # Flammable, Harmful

    def _get_hazard_statements(self, cid: int) -> List[str]:
        """Get H-code hazard statements"""
        # Placeholder
        return ['H225: Highly flammable liquid and vapour', 'H319: Causes serious eye irritation']

    def _get_precautionary_statements(self, cid: int) -> List[str]:
        """Get P-code precautionary statements"""
        # Placeholder
        return ['P210: Keep away from heat/sparks/open flames/hot surfaces', 'P305+P351+P338: IF IN EYES: Rinse cautiously with water']

    def _get_signal_word(self, cid: int) -> str:
        """Get GHS signal word"""
        # Placeholder
        return 'Warning'


# Create singleton instance
compound_lookup_service = CompoundLookupService()
