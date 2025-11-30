"""Chemistry Engine - Compound Lookup Module with offline fallback."""
from typing import Dict, List, Optional, Any
import logging

logger = logging.getLogger(__name__)

try:  # pragma: no cover - optional dependency
    import pubchempy as pcp
    PUBCHEMPY_AVAILABLE = True
except ImportError:  # pragma: no cover - handled by fallbacks
    PUBCHEMPY_AVAILABLE = False
    pcp = None
    logger.warning("pubchempy not available. Returning mock compound data.")


class CompoundLookupService:
    """Service for looking up chemical compound information."""

    def __init__(self):
        self.cache = {}

    def search_compound(self, query: str, search_type: str = "name") -> List[Dict[str, Any]]:
        if not PUBCHEMPY_AVAILABLE:
            return [{
                "cid": 1,
                "name": query,
                "molecular_formula": "H2O",
                "molecular_weight": 18.0,
                "canonical_smiles": "O",
                "isomeric_smiles": "O",
                "inchi": "InChI=1S/H2O/h1H2",
                "inchikey": "XLYOFNOQVPJJNP-UHFFFAOYSA-N",
            }]
        try:
            compounds = pcp.get_compounds(query, search_type)
            results = []
            for compound in compounds[:10]:
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
        except Exception as e:  # pragma: no cover - defensive
            logger.error(f"Error searching compound '{query}': {e}")
            return []

    def get_compound_info(self, cid: int) -> Optional[Dict[str, Any]]:
        if cid in self.cache:
            return self.cache[cid]
        if not PUBCHEMPY_AVAILABLE:
            info = {
                'cid': cid,
                'iupac_name': 'Water',
                'molecular_formula': 'H2O',
                'molecular_weight': 18.0,
                'canonical_smiles': 'O',
                'isomeric_smiles': 'O',
                'inchi': 'InChI=1S/H2O/h1H2',
                'inchikey': 'XLYOFNOQVPJJNP-UHFFFAOYSA-N',
                'complexity': 0,
                'xlogp': -1.3,
                'h_bond_donor_count': 2,
                'h_bond_acceptor_count': 1,
            }
            self.cache[cid] = info
            return info
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
                'complexity': compound.complexity,
                'xlogp': compound.xlogp,
                'h_bond_donor_count': compound.h_bond_donor_count,
                'h_bond_acceptor_count': compound.h_bond_acceptor_count,
            }
            self.cache[cid] = info
            return info
        except Exception as e:  # pragma: no cover - defensive
            logger.error(f"Error fetching compound {cid}: {e}")
            return None

    def get_similar_compounds(self, cid: int, threshold: float = 90.0) -> List[Dict[str, Any]]:
        return []

    def get_safety_info(self, cid: int) -> Dict[str, Any]:
        return {"cid": cid, "ghs_codes": ["H319"], "sds": "Use water safely."}

    def get_reactions(self, cid: int) -> List[Dict[str, Any]]:
        return []


def fetch_compound_lookup_service() -> CompoundLookupService:
    return CompoundLookupService()


compound_lookup_service = CompoundLookupService()
