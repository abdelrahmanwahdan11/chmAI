"""Structure analysis utilities with safe fallbacks when RDKit is unavailable."""
import io
from typing import Dict, Any, List, Optional
import logging

logger = logging.getLogger(__name__)

try:  # pragma: no cover - optional dependency
    from rdkit import Chem
    from rdkit.Chem import AllChem, Descriptors, Draw
    from rdkit.Chem import rdMolDescriptors
    RDKIT_AVAILABLE = True
except ImportError:  # pragma: no cover - handled by fallbacks
    RDKIT_AVAILABLE = False
    logger.warning("RDKit not available. Structure analysis features will use mock data.")


class StructureAnalysisService:
    """Service for molecular structure analysis with graceful degradation."""

    def _mock_structure(self, smiles: str, include_z: bool = False) -> Dict[str, Any]:
        atoms = [
            {"id": 0, "symbol": "C", "atomic_number": 6, "x": 0.0, "y": 0.0, "z": 0.0},
            {"id": 1, "symbol": "O", "atomic_number": 8, "x": 1.2, "y": 0.0, "z": 0.1 if include_z else 0.0},
        ]
        bonds = [{"atom1": 0, "atom2": 1, "type": 2, "is_aromatic": False}]
        return {
            "smiles": smiles,
            "formula": "CO",
            "atoms": atoms,
            "bonds": bonds,
            "descriptors": {"mock": True},
            "is_3d": include_z,
        }

    def get_molecule_data(self, smiles: str) -> Dict[str, Any]:
        if not RDKIT_AVAILABLE:
            return self._mock_structure(smiles)
        # RDKit path retained for completeness
        mol = Chem.MolFromSmiles(smiles)
        if not mol:
            raise ValueError("Invalid SMILES string")
        AllChem.Compute2DCoords(mol)
        conf = mol.GetConformer()

        atoms = []
        for atom in mol.GetAtoms():
            pos = conf.GetAtomPosition(atom.GetIdx())
            atoms.append({
                "id": atom.GetIdx(),
                "symbol": atom.GetSymbol(),
                "atomic_number": atom.GetAtomicNum(),
                "x": pos.x,
                "y": pos.y,
                "z": pos.z,
                "charge": atom.GetFormalCharge(),
                "hybridization": str(atom.GetHybridization()),
                "implicit_valence": atom.GetImplicitValence(),
                "explicit_valence": atom.GetExplicitValence(),
            })

        bonds = []
        for bond in mol.GetBonds():
            bonds.append({
                "atom1": bond.GetBeginAtomIdx(),
                "atom2": bond.GetEndAtomIdx(),
                "type": int(bond.GetBondTypeAsDouble()),
                "is_aromatic": bond.GetIsAromatic(),
            })

        return {
            "smiles": smiles,
            "formula": rdMolDescriptors.CalcMolFormula(mol),
            "atoms": atoms,
            "bonds": bonds,
            "descriptors": self._calculate_basic_descriptors(mol),
        }

    def get_3d_structure(self, smiles: str) -> Dict[str, Any]:
        if not RDKIT_AVAILABLE:
            return self._mock_structure(smiles, include_z=True)
        mol = Chem.MolFromSmiles(smiles)
        if not mol:
            raise ValueError("Invalid SMILES")
        mol = Chem.AddHs(mol)
        params = AllChem.ETKDGv3()
        params.useRandomCoords = True
        result = AllChem.EmbedMolecule(mol, params)
        if result == -1:
            logger.warning("3D embedding failed, falling back to mock data")
            return self._mock_structure(smiles, include_z=True)
        AllChem.MMFFOptimizeMolecule(mol)
        conf = mol.GetConformer()

        atoms = []
        for atom in mol.GetAtoms():
            pos = conf.GetAtomPosition(atom.GetIdx())
            atoms.append({
                "id": atom.GetIdx(),
                "symbol": atom.GetSymbol(),
                "atomic_number": atom.GetAtomicNum(),
                "x": pos.x,
                "y": pos.y,
                "z": pos.z,
            })

        bonds = []
        for bond in mol.GetBonds():
            bonds.append({
                "atom1": bond.GetBeginAtomIdx(),
                "atom2": bond.GetEndAtomIdx(),
                "type": int(bond.GetBondTypeAsDouble()),
                "is_aromatic": bond.GetIsAromatic(),
            })

        return {
            "smiles": smiles,
            "formula": rdMolDescriptors.CalcMolFormula(mol),
            "atoms": atoms,
            "bonds": bonds,
            "is_3d": True,
        }

    def calculate_descriptors(self, smiles: str) -> Dict[str, Any]:
        if not RDKIT_AVAILABLE:
            return {
                "basic": {"formula": "CO"},
                "physicochemical": {"molecular_weight": 28.0, "logp": 0.0},
            }
        mol = Chem.MolFromSmiles(smiles)
        if not mol:
            raise ValueError("Invalid SMILES")
        return {
            "basic": {
                "formula": rdMolDescriptors.CalcMolFormula(mol),
                "atom_count": mol.GetNumAtoms(),
            },
            "physicochemical": {
                "molecular_weight": Descriptors.MolWt(mol),
                "logp": Descriptors.MolLogP(mol),
            },
        }

    def _calculate_basic_descriptors(self, mol) -> Dict[str, Any]:  # pragma: no cover - RDKit path only
        return {
            "formula": rdMolDescriptors.CalcMolFormula(mol),
            "atom_count": mol.GetNumAtoms(),
        }

    def generate_image(self, smiles: str, width: int = 400, height: int = 400) -> bytes:
        if not RDKIT_AVAILABLE:
            return b""
        mol = Chem.MolFromSmiles(smiles)
        if not mol:
            raise ValueError("Invalid SMILES")
        AllChem.Compute2DCoords(mol)
        img = Draw.MolToImage(mol, size=(width, height))
        img_bytes = io.BytesIO()
        img.save(img_bytes, format='PNG')
        return img_bytes.getvalue()


def fetch_structure_analysis_service() -> StructureAnalysisService:
    return StructureAnalysisService()


structure_analysis_service = StructureAnalysisService()
