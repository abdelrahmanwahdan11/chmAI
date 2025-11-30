from typing import Dict, Any, List, Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from chemistry_engine import (
    compound_lookup_service,
    periodic_table_service,
    reaction_engine_service,
    structure_analysis_service
)

router = APIRouter(
    prefix="/api/chemistry",
    tags=["chemistry"]
)

# Pydantic Models
class CompoundSearchRequest(BaseModel):
    query: str
    search_type: str = "name"  # name, formula, smiles, cas


class ElementRequest(BaseModel):
    identifier: str | int


class EquationBalanceRequest(BaseModel):
    equation: str


class StoichiometryRequest(BaseModel):
    equation: str
    given_substance: str
    given_amount: float
    target_substance: str
    unit: str = "mol"


class PHCalculationRequest(BaseModel):
    concentration: float
    substance_type: str = "strong_acid"
    pka: Optional[float] = None


class BufferCalculationRequest(BaseModel):
    target_ph: float
    pka: float
    total_concentration: float = 0.1


class DilutionRequest(BaseModel):
    initial_concentration: float
    initial_volume: float
    final_concentration: Optional[float] = None
    final_volume: Optional[float] = None


# ======================
# COMPOUND ENDPOINTS
# ======================

@router.post("/compounds/search")
async def search_compounds(request: CompoundSearchRequest):
    """Search for chemical compounds by name, formula, SMILES, etc."""
    try:
        results = compound_lookup_service.search_compound(
            request.query,
            request.search_type
        )
        return {"results": results, "count": len(results)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compounds/{cid}")
async def get_compound_details(cid: int):
    """Get comprehensive information about a compound by PubChem CID"""
    try:
        compound_info = compound_lookup_service.get_compound_info(cid)
        if not compound_info:
            raise HTTPException(status_code=404, detail="Compound not found")
        return compound_info
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compounds/{cid}/similar")
async def get_similar_compounds(cid: int, threshold: float = 90.0):
    """Find structurally similar compounds"""
    try:
        similar = compound_lookup_service.get_similar_compounds(cid, threshold)
        return {"cid": cid, "similar_compounds": similar, "count": len(similar)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compounds/{cid}/safety")
async def get_safety_information(cid: int):
    """Get safety and hazard information for a compound"""
    try:
        safety_info = compound_lookup_service.get_safety_info(cid)
        return safety_info
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compounds/{cid}/reactions")
async def get_compound_reactions(cid: int):
    """Get known reactions involving this compound"""
    try:
        reactions = compound_lookup_service.get_reactions(cid)
        return {"cid": cid, "reactions": reactions}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ======================
# STRUCTURE ENDPOINTS
# ======================

class StructureRequest(BaseModel):
    smiles: str


@router.post("/structure/2d")
async def get_2d_structure(request: StructureRequest):
    """Get 2D structure data for visualization from SMILES"""
    try:
        data = structure_analysis_service.get_molecule_data(request.smiles)
        return data
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/structure/3d")
async def get_3d_structure(request: StructureRequest):
    """Get 3D structure coordinates for visualization from SMILES"""
    try:
        data = structure_analysis_service.get_3d_structure(request.smiles)
        return data
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/structure/descriptors")
async def calculate_descriptors(request: StructureRequest):
    """Calculate comprehensive molecular descriptors from SMILES"""
    try:
        descriptors = structure_analysis_service.calculate_descriptors(request.smiles)
        return descriptors
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/structure/image")
async def get_structure_image(smiles: str, width: int = 400, height: int = 400):
    """Generate molecular structure image as PNG"""
    from fastapi.responses import Response
    try:
        image_bytes = structure_analysis_service.generate_image(smiles, width, height)
        return Response(content=image_bytes, media_type="image/png")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ======================
# PERIODIC TABLE ENDPOINTS
# ======================

@router.get("/periodic-table")
async def get_periodic_table():
    """Get the complete periodic table"""
    try:
        elements = periodic_table_service.get_periodic_table()
        return {"elements": elements, "count": len(elements)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/periodic-table/element")
async def get_element_info(request: ElementRequest):
    """Get detailed information about a specific element"""
    try:
        element_info = periodic_table_service.get_element(request.identifier)
        if not element_info:
            raise HTTPException(status_code=404, detail="Element not found")
        return element_info
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/periodic-table/search")
async def search_elements(criteria: Dict[str, Any]):
    """Search for elements matching specific criteria"""
    try:
        results = periodic_table_service.search_elements(criteria)
        return {"results": results, "count": len(results)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/periodic-table/element/{symbol}/isotopes")
async def get_element_isotopes(symbol: str):
    """Get isotope information for an element"""
    try:
        isotopes = periodic_table_service.get_isotopes(symbol)
        return {"element": symbol, "isotopes": isotopes}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ======================
# REACTION & CALCULATION ENDPOINTS
# ======================

@router.post("/reactions/balance")
async def balance_chemical_equation(request: EquationBalanceRequest):
    """Balance a chemical equation"""
    try:
        result = reaction_engine_service.balance_equation(request.equation)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/reactions/stoichiometry")
async def calculate_stoichiometry(request: StoichiometryRequest):
    """Calculate stoichiometric amounts"""
    try:
        result = reaction_engine_service.calculate_stoichiometry(
            request.equation,
            request.given_substance,
            request.given_amount,
            request.target_substance,
            request.unit
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/calculations/ph")
async def calculate_ph(request: PHCalculationRequest):
    """Calculate pH of a solution"""
    try:
        result = reaction_engine_service.calculate_ph(
            request.concentration,
            request.substance_type,
            request.pka
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/calculations/buffer")
async def calculate_buffer(request: BufferCalculationRequest):
    """Calculate buffer solution composition"""
    try:
        result = reaction_engine_service.buffer_calculator(
            request.target_ph,
            request.pka,
            request.total_concentration
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/calculations/dilution")
async def calculate_dilution(request: DilutionRequest):
    """Calculate dilution parameters"""
    try:
        result = reaction_engine_service.dilution_calculator(
            request.initial_concentration,
            request.initial_volume,
            request.final_concentration,
            request.final_volume
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/calculations/molar-mass")
async def calculate_molar_mass(formula: str):
    """Calculate molar mass from chemical formula"""
    try:
        molar_mass = periodic_table_service.calculate_molar_mass(formula)
        if molar_mass is None:
            raise HTTPException(status_code=400, detail="Invalid chemical formula")
        return {
            "formula": formula,
            "molar_mass": molar_mass,
            "unit": "g/mol"
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
