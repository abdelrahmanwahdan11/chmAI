import io
from typing import Dict, Any, List, Optional
import logging
try:
    from rdkit import Chem
    from rdkit.Chem import AllChem, Descriptors, Draw
    from rdkit.Chem import rdMolDescriptors
    RDKIT_AVAILABLE = True
except ImportError:
    RDKIT_AVAILABLE = False
    logger.warning("RDKit not available. Structure analysis features will be disabled.")

logger = logging.getLogger(__name__)

class StructureAnalysisService:
    """
    Service for molecular structure analysis using RDKit.
    Provides functionality for:
    - 2D/3D coordinate generation
    - Molecular descriptors calculation
    - Structure format conversion
    - Image generation
    """

    def get_molecule_data(self, smiles: str) -> Dict[str, Any]:
        """
        Generate atom and bond data for frontend rendering from SMILES.
        """
        if not RDKIT_AVAILABLE:
            raise ImportError("RDKit is not installed.")
        try:
            mol = Chem.MolFromSmiles(smiles)
            if not mol:
                raise ValueError("Invalid SMILES string")

            # Add hydrogens for 3D structure if needed, but for 2D usually we keep implicit
            # mol = Chem.AddHs(mol)

            # Generate 2D coordinates
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
                    "type": int(bond.GetBondTypeAsDouble()), # 1.0, 1.5, 2.0, 3.0
                    "is_aromatic": bond.GetIsAromatic(),
                })

            return {
                "smiles": smiles,
                "formula": rdMolDescriptors.CalcMolFormula(mol),
                "atoms": atoms,
                "bonds": bonds,
                "descriptors": self._calculate_basic_descriptors(mol)
            }

        except Exception as e:
            logger.error(f"Error analyzing structure: {str(e)}")
            raise

    def get_3d_structure(self, smiles: str) -> Dict[str, Any]:
        """
        Generate 3D coordinates for a molecule.
        """
        if not RDKIT_AVAILABLE:
            raise ImportError("RDKit is not installed.")
        try:
            mol = Chem.MolFromSmiles(smiles)
            if not mol:
                raise ValueError("Invalid SMILES")

            mol = Chem.AddHs(mol)
            
            # Generate 3D conformation
            # ETKDGv3 is a good default embedding method
            params = AllChem.ETKDGv3()
            params.useRandomCoords = True
            result = AllChem.EmbedMolecule(mol, params)
            
            # If embedding fails, fallback to 2D
            if result == -1:
                logger.warning("3D embedding failed, falling back to 2D coordinates")
                return self.get_molecule_data(smiles)
            
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
            
            # Add bonds for visualization
            bonds = []
            for bond in mol.GetBonds():
                bonds.append({
                    "atom1": bond.GetBeginAtomIdx(),
                    "atom2": bond.GetEndAtomIdx(),
                    "type": float(bond.GetBondTypeAsDouble()),  # 1.0, 1.5, 2.0, 3.0
                    "is_aromatic": bond.GetIsAromatic(),
                })
                
            # Generate MolBlock for other viewers
            mol_block = Chem.MolToMolBlock(mol)

            return {
                "smiles": smiles,
                "formula": rdMolDescriptors.CalcMolFormula(mol),
                "atoms": atoms,
                "bonds": bonds,
                "mol_block": mol_block,
                "format": "mol3000",
                "is_3d": True
            }

        except Exception as e:
            logger.error(f"Error generating 3D structure: {str(e)}")
            # Fallback to 2D if 3D fails
            return self.get_molecule_data(smiles)

    def calculate_descriptors(self, smiles: str) -> Dict[str, Any]:
        """
        Calculate comprehensive molecular descriptors.
        """
        if not RDKIT_AVAILABLE:
            raise ImportError("RDKit is not installed.")
        try:
            mol = Chem.MolFromSmiles(smiles)
            if not mol:
                raise ValueError("Invalid SMILES")

            return {
                "basic": self._calculate_basic_descriptors(mol),
                "physicochemical": {
                    "logp": Descriptors.MolLogP(mol),
                    "tpsa": Descriptors.TPSA(mol),
                    "exact_mw": Descriptors.ExactMolWt(mol),
                    "heavy_atom_count": Descriptors.HeavyAtomCount(mol),
                    "ring_count": Descriptors.RingCount(mol),
                    "rotatable_bonds": Descriptors.NumRotatableBonds(mol),
                    "h_bond_donors": Descriptors.NumHDonors(mol),
                    "h_bond_acceptors": Descriptors.NumHAcceptors(mol),
                },
                "connectivity": {
                    "bertz_ct": Descriptors.BertzCT(mol),
                    "balaban_j": Descriptors.BalabanJ(mol),
                    "hall_kier_alpha": Descriptors.HallKierAlpha(mol),
                },
                "composition": {
                    "fraction_csp3": Descriptors.FractionCSP3(mol),
                    "num_heteroatoms": Descriptors.NumHeteroatoms(mol),
                }
            }
        except Exception as e:
            logger.error(f"Error calculating descriptors: {str(e)}")
            raise

    def _calculate_basic_descriptors(self, mol) -> Dict[str, Any]:
        return {
            "molecular_weight": Descriptors.MolWt(mol),
            "formula": rdMolDescriptors.CalcMolFormula(mol),
            "num_atoms": mol.GetNumAtoms(),
            "num_bonds": mol.GetNumBonds(),
        }

    def generate_image(self, smiles: str, width: int = 400, height: int = 400) -> bytes:
        """
        Generate a PNG image of the molecule.
        """
        if not RDKIT_AVAILABLE:
            raise ImportError("RDKit is not installed.")
        try:
            mol = Chem.MolFromSmiles(smiles)
            if not mol:
                raise ValueError("Invalid SMILES")
            
            AllChem.Compute2DCoords(mol)
            img = Draw.MolToImage(mol, size=(width, height))
            
            img_byte_arr = io.BytesIO()
            img.save(img_byte_arr, format='PNG')
            return img_byte_arr.getvalue()
            
        except Exception as e:
            logger.error(f"Error generating image: {str(e)}")
            raise

# Singleton instance
structure_analysis_service = StructureAnalysisService()
