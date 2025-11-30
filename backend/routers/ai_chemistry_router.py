"""
AI Chemistry API Router
Provides intelligent chemistry analysis endpoints
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import os

from chemistry_engine import get_ai_chemistry_service

router = APIRouter(prefix="/api/chemistry/ai", tags=["ai"])

# Get API key from environment
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# Dependency to get AI service
def get_ai_service():
    if not GEMINI_API_KEY:
        raise HTTPException(
            status_code=500,
            detail="Gemini API key not configured"
        )
    return get_ai_chemistry_service(GEMINI_API_KEY)


# Request/Response Models
class CompoundAnalysisRequest(BaseModel):
    cid: int
    compound_name: str
    molecular_formula: str
    smiles: Optional[str] = None
    properties: Dict[str, Any] = {}
    analysis_type: str = "general"  # general, safety, applications, synthesis
    language: str = "en"  # en, ar


class ReactionPredictionRequest(BaseModel):
    reactants: List[str]  # List of SMILES or compound names
    conditions: Optional[Dict[str, Any]] = None
    language: str = "en"


class StructureExplanationRequest(BaseModel):
    smiles: str
    compound_name: Optional[str] = None
    focus: str = "general"  # general, bonding, geometry, properties
    language: str = "en"


class AlternativesRequest(BaseModel):
    compound_name: str
    molecular_formula: str
    current_use: str
    criteria: str = "safer"  # safer, cheaper, greener
    language: str = "en"


# Endpoints
@router.post("/analyze-compound")
async def analyze_compound(
    request: CompoundAnalysisRequest,
    ai_service=Depends(get_ai_service)
):
    """
    Analyze a chemical compound using AI.
    
    Returns intelligent analysis including:
    - Overview and properties
    - Safety assessment
    - Applications
    - Synthesis routes
    """
    try:
        result = ai_service.analyze_compound(
            compound_name=request.compound_name,
            molecular_formula=request.molecular_formula,
            smiles=request.smiles,
            properties=request.properties,
            analysis_type=request.analysis_type,
            language=request.language
        )
        
        if "error" in result:
            raise HTTPException(status_code=500, detail=result["error"])
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/predict-reaction")
async def predict_reaction(
    request: ReactionPredictionRequest,
    ai_service=Depends(get_ai_service)
):
    """
    Predict possible reactions between compounds.
    
    Returns:
    - Predicted products
    - Reaction mechanism
    - Safety considerations
    - Yield estimates
    """
    try:
        if len(request.reactants) < 2:
            raise HTTPException(
                status_code=400,
                detail="At least 2 reactants required"
            )
        
        result = ai_service.predict_reaction(
            reactants=request.reactants,
            conditions=request.conditions,
            language=request.language
        )
        
        if "error" in result:
            raise HTTPException(status_code=500, detail=result["error"])
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/explain-structure")
async def explain_structure(
    request: StructureExplanationRequest,
    ai_service=Depends(get_ai_service)
):
    """
    Explain molecular structure in educational terms.
    
    Returns:
    - Geometry description
    - Functional groups
    - Bonding characteristics
    - Structure-property relationships
    """
    try:
        result = ai_service.explain_structure(
            smiles=request.smiles,
            compound_name=request.compound_name,
            focus=request.focus,
            language=request.language
        )
        
        if "error" in result:
            raise HTTPException(status_code=500, detail=result["error"])
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/suggest-alternatives")
async def suggest_alternatives(
    request: AlternativesRequest,
    ai_service=Depends(get_ai_service)
):
    """
    Suggest alternative compounds based on criteria.
    
    Returns:
    - List of alternatives
    - Advantages/disadvantages
    - Cost/safety comparisons
    - Best recommendation
    """
    try:
        result = ai_service.suggest_alternatives(
            compound_name=request.compound_name,
            molecular_formula=request.molecular_formula,
            current_use=request.current_use,
            criteria=request.criteria,
            language=request.language
        )
        
        if "error" in result:
            raise HTTPException(status_code=500, detail=result["error"])
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


class SubstitutionRequest(BaseModel):
    original: str
    candidate: str
    language: str = "en"

@router.post("/analyze-substitution")
async def analyze_substitution(
    request: SubstitutionRequest,
    ai_service=Depends(get_ai_service)
):
    """
    Analyze if a candidate chemical is a good substitute for an original one.
    """
    try:
        result = ai_service.analyze_substitution(
            original=request.original,
            candidate=request.candidate,
            language=request.language
        )
        
        if "error" in result:
            raise HTTPException(status_code=500, detail=result["error"])
        
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
