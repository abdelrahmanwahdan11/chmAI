from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from pydantic import BaseModel
import os
from dotenv import load_dotenv
import google.generativeai as genai
import json

from database import SessionLocal, engine, Base
from models import Material, Recipe, RecipeItem
from modules.ai_assistant_engine.prompts import MASTER_SYSTEM_PROMPT
from routers import chemistry_router
from routers import ai_chemistry_router
from routers import inventory_router

# Load environment variables
load_dotenv()

# Configure Gemini
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    print("WARNING: GEMINI_API_KEY not found in environment variables.")
else:
    genai.configure(api_key=GEMINI_API_KEY)

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="ChemAI Industrial OS", version="1.0.0")

# Add CORS middleware
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Include routers
app.include_router(chemistry_router.router)
app.include_router(ai_chemistry_router.router)
app.include_router(inventory_router.router)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Pydantic Models
class RecipeItemInput(BaseModel):
    material_id: int
    percentage: float # 0-100

class FormulaInput(BaseModel):
    name: str
    items: List[RecipeItemInput]
    total_batch_weight_kg: float = 1000.0

class AnalysisResult(BaseModel):
    total_cost: float
    cost_per_kg: float
    inventory_status: str
    missing_materials: List[str]
    safety_hazards: List[str]
    ghs_icons: List[str]

class VariationRequest(BaseModel):
    product_name: str
    description: str
    language: str = "en" # "en" or "ar"

class VariationItem(BaseModel):
    type: str
    ingredients: List[str]
    steps: List[str]
    warnings: List[str]
    difference_explanation: str

class VariationsResponse(BaseModel):
    variations: List[VariationItem]

@app.post("/analyze_formula", response_model=AnalysisResult)
def analyze_formula_with_cost_and_safety(formula: FormulaInput, db: Session = Depends(get_db)):
    total_cost = 0.0
    missing_materials = []
    safety_hazards = set()
    ghs_icons = set()
    inventory_ok = True

    for item in formula.items:
        material = db.query(Material).filter(Material.id == item.material_id).first()
        
        if not material:
            raise HTTPException(status_code=404, detail=f"Material ID {item.material_id} not found")
        
        weight_needed = (item.percentage / 100.0) * formula.total_batch_weight_kg
        material_cost = weight_needed * material.price_per_kg
        total_cost += material_cost

        if material.inventory_level < weight_needed:
            inventory_ok = False
            missing_materials.append(f"{material.name} (Need {weight_needed}kg, Have {material.inventory_level}kg)")

        if material.ghs_tags:
            for tag in material.ghs_tags:
                safety_hazards.add(tag)
                if tag in ["H314", "H318"]: ghs_icons.add("Corrosive")
                if tag in ["H224", "H225", "H226"]: ghs_icons.add("Flammable")
                if tag in ["H300", "H301", "H302"]: ghs_icons.add("Toxic")

    return AnalysisResult(
        total_cost=round(total_cost, 2),
        cost_per_kg=round(total_cost / formula.total_batch_weight_kg, 2),
        inventory_status="OK" if inventory_ok else "Insufficient Stock",
        missing_materials=missing_materials,
        safety_hazards=list(safety_hazards),
        ghs_icons=list(ghs_icons)
    )

@app.post("/generate_variations", response_model=VariationsResponse)
async def generate_six_variations(request: VariationRequest):
    """
    Generates 6 distinct recipe variations using Gemini AI.
    """
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="Gemini API Key not configured.")

    model = genai.GenerativeModel('gemini-1.5-flash')
    
    lang_instruction = "Respond in English." if request.language == "en" else "Respond in Arabic (اللغة العربية)."

    prompt = f"""
    {MASTER_SYSTEM_PROMPT}

    TASK: Generate exactly 6 distinct industrial chemical formulations for a product.
    PRODUCT NAME: {request.product_name}
    DESCRIPTION: {request.description}
    LANGUAGE: {lang_instruction}

    REQUIRED VARIATIONS:
    1. Standard/Balanced (The baseline high-quality formula)
    2. Economic (Low cost, reduced active matter, cheaper fillers)
    3. Premium (High performance, expensive additives, superior sensory feel)
    4. Eco-Friendly (Biodegradable, no harsh chemicals, green certification ready)
    5. Concentrated (High active matter, low water, heavy duty)
    6. Innovative (Unique additive or mechanism, e.g., encapsulation, color changing)

    OUTPUT FORMAT:
    Return ONLY a valid JSON object with this structure:
    {{
      "variations": [
        {{
          "type": "Name of Variation (e.g., Economic)",
          "ingredients": ["Ingredient Name %", ...],
          "steps": ["Step 1...", "Step 2..."],
          "warnings": ["Specific safety warning..."],
          "difference_explanation": "Why this is different from the standard..."
        }},
        ... (total 6 items)
      ]
    }}
    """

    try:
        response = model.generate_content(prompt)
        # Clean response text to ensure it's valid JSON
        text = response.text.strip()
        if text.startswith("```json"):
            text = text[7:-3]
        elif text.startswith("```"):
            text = text[3:-3]
        
        data = json.loads(text)
        return VariationsResponse(**data)
    except Exception as e:
        print(f"AI Generation Error: {e}")
        raise HTTPException(status_code=500, detail=f"AI Generation Failed: {str(e)}")

@app.get("/")
def read_root():
    return {"message": "ChemAI Industrial OS Backend is Running"}

@app.get("/debug/config")
def debug_config():
    """Debug endpoint to check what models are available"""
    import sys
    try:
        # Try to list available models
        available_models = []
        try:
            import google.generativeai as genai
            if GEMINI_API_KEY:
                genai.configure(api_key=GEMINI_API_KEY)
                models = genai.list_models()
                available_models = [model.name for model in models if 'generateContent' in model.supported_generation_methods]
        except Exception as e:
            available_models = [f"Error: {str(e)}"]
        
        return {
            "status": "Server is running",
            "api_key_configured": bool(GEMINI_API_KEY),
            "api_key_preview": GEMINI_API_KEY[:15] + "..." if GEMINI_API_KEY else None,
            "available_models": available_models,
            "python_version": sys.version,
            "current_model_in_code": "gemini-1.5-flash",
            "file_path": __file__
        }
    except Exception as e:
        return {"error": str(e)}
