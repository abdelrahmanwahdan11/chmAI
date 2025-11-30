"""
AI Chemistry Service
Provides intelligent chemistry analysis using Gemini AI
"""
import google.generativeai as genai
from typing import Dict, Any, List, Optional
import json
import logging
from functools import lru_cache
import hashlib

logger = logging.getLogger(__name__)

class AIChemistryService:
    """
    Service for AI-powered chemistry analysis using Gemini.
    """
    
    SYSTEM_PROMPT = """You are an expert chemistry AI assistant with deep knowledge of:
- Organic and inorganic chemistry
- Chemical reactions and mechanisms
- Safety protocols and hazard assessment
- Industrial applications
- Green chemistry principles
- Analytical chemistry

Provide accurate, educational, and safety-conscious responses.
Always cite when uncertain and prioritize user safety."""

    def __init__(self, api_key: str):
        """Initialize the AI service with Gemini API key."""
        if not api_key:
            raise ValueError("Gemini API key is required")
        
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash')
    
    def _create_cache_key(self, *args) -> str:
        """Create a cache key from arguments."""
        content = ''.join(str(arg) for arg in args)
        return hashlib.md5(content.encode()).hexdigest()
    
    @lru_cache(maxsize=100)
    def analyze_compound(
        self,
        compound_name: str,
        molecular_formula: str,
        smiles: Optional[str],
        properties: Dict[str, Any],
        analysis_type: str = "general",
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Analyze a chemical compound using AI.
        
        Args:
            compound_name: Name of the compound
            molecular_formula: Chemical formula
            smiles: SMILES notation
            properties: Dictionary of compound properties
            analysis_type: Type of analysis (general, safety, applications, synthesis)
            language: Response language (en, ar)
        
        Returns:
            Dictionary with AI analysis
        """
        try:
            lang_instruction = (
                "Respond in English." if language == "en" 
                else "Respond in Arabic (اللغة العربية)."
            )
            
            # Build context from compound data
            context = f"""
COMPOUND: {compound_name}
MOLECULAR FORMULA: {molecular_formula}
SMILES: {smiles or 'Not available'}
MOLECULAR WEIGHT: {properties.get('molecular_weight', 'N/A')} g/mol
"""
            
            if analysis_type == "general":
                prompt = f"""{self.SYSTEM_PROMPT}

{context}

Provide a comprehensive analysis of this compound including:
1. Brief overview and common names
2. Key chemical properties
3. Common uses and applications
4. Interesting facts or industrial significance

{lang_instruction}
Format your response as JSON:
{{
  "overview": "Brief description",
  "properties": ["Key property 1", "Key property 2", ...],
  "applications": ["Application 1", "Application 2", ...],
  "facts": ["Fact 1", "Fact 2", ...]
}}
"""
            
            elif analysis_type == "safety":
                prompt = f"""{self.SYSTEM_PROMPT}

{context}

Provide detailed safety analysis:
1. Hazard classification
2. Handling precautions
3. Storage requirements
4. Emergency procedures
5. Personal protective equipment (PPE)

{lang_instruction}
Format as JSON:
{{
  "hazard_level": "Low|Moderate|High|Severe",
  "hazards": ["Hazard 1", "Hazard 2", ...],
  "precautions": ["Precaution 1", ...],
  "storage": "Storage instructions",
  "ppe": ["PPE item 1", ...],
  "first_aid": "First aid measures"
}}
"""
            
            elif analysis_type == "applications":
                prompt = f"""{self.SYSTEM_PROMPT}

{context}

List and explain potential applications:
1. Industrial uses
2. Laboratory applications
3. Consumer products
4. Research applications
5. Emerging uses

{lang_instruction}
Format as JSON:
{{
  "industrial": ["Use 1", ...],
  "laboratory": ["Use 1", ...],
  "consumer": ["Use 1", ...],
  "research": ["Use 1", ...],
  "emerging": ["Use 1", ...]
}}
"""
            
            elif analysis_type == "synthesis":
                prompt = f"""{self.SYSTEM_PROMPT}

{context}

Suggest synthesis routes:
1. Common synthesis methods
2. Starting materials
3. Key reaction steps
4. Industrial vs laboratory methods
5. Green chemistry alternatives

{lang_instruction}
Format as JSON:
{{
  "methods": [
    {{
      "name": "Method name",
      "starting_materials": ["Material 1", ...],
      "steps": ["Step 1", ...],
      "type": "Industrial|Laboratory|Green",
      "difficulty": "Easy|Moderate|Difficult"
    }}
  ],
  "notes": "Additional notes"
}}
"""
            
            else:
                raise ValueError(f"Unknown analysis type: {analysis_type}")
            
            # Generate response
            response = self.model.generate_content(prompt)
            text = self._clean_json_response(response.text)
            
            result = json.loads(text)
            result['analysis_type'] = analysis_type
            result['compound'] = compound_name
            
            return result
            
        except Exception as e:
            logger.error(f"Error analyzing compound: {e}")
            return {
                "error": str(e),
                "analysis_type": analysis_type,
                "compound": compound_name
            }
    
    def predict_reaction(
        self,
        reactants: List[str],
        conditions: Optional[str] = None,
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Predict possible reactions between compounds.
        
        Args:
            reactants: List of SMILES strings
            conditions: Reaction conditions (temperature, catalyst, etc.)
            language: Response language
        
        Returns:
            Dictionary with reaction predictions
        """
        try:
            lang_instruction = (
                "Respond in English." if language == "en"
                else "Respond in Arabic (اللغة العربية)."
            )
            
            reactants_str = "\n".join(f"- {r}" for r in reactants)
            conditions_str = conditions or "Standard conditions"
            
            prompt = f"""{self.SYSTEM_PROMPT}

REACTANTS (SMILES):
{reactants_str}

CONDITIONS: {conditions_str}

Predict possible reactions:
1. Most likely reaction
2. Products formed
3. Reaction mechanism overview
4. Side reactions
5. Safety considerations

{lang_instruction}
Format as JSON:
{{
  "main_reaction": {{
    "products": ["Product 1 SMILES", ...],
    "product_names": ["Product 1 name", ...],
    "mechanism": "Brief mechanism description",
    "conditions_needed": "Optimal conditions"
  }},
  "side_reactions": ["Side reaction 1", ...],
  "safety": ["Safety note 1", ...],
  "yield_estimate": "High|Moderate|Low",
  "notes": "Additional notes"
}}
"""
            
            response = self.model.generate_content(prompt)
            text = self._clean_json_response(response.text)
            
            result = json.loads(text)
            result['reactants'] = reactants
            result['conditions'] = conditions
            
            return result
            
        except Exception as e:
            logger.error(f"Error predicting reaction: {e}")
            return {
                "error": str(e),
                "reactants": reactants
            }
    
    def explain_structure(
        self,
        smiles: str,
        compound_name: Optional[str] = None,
        focus: str = "general",
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Explain molecular structure.
        
        Args:
            smiles: SMILES notation
            compound_name: Optional compound name
            focus: Focus area (general, bonding, geometry, properties)
            language: Response language
        
        Returns:
            Dictionary with structure explanation
        """
        try:
            lang_instruction = (
                "Respond in English." if language == "en"
                else "Respond in Arabic (اللغة العربية)."
            )
            
            name_str = f"({compound_name})" if compound_name else ""
            
            prompt = f"""{self.SYSTEM_PROMPT}

MOLECULAR STRUCTURE {name_str}:
SMILES: {smiles}

Explain the molecular structure focusing on:
1. Overall shape and geometry
2. Functional groups present
3. Bonding characteristics
4. Stereochemistry (if applicable)
5. Structure-property relationships

{lang_instruction}
Format as JSON:
{{
  "geometry": "Description of molecular geometry",
  "functional_groups": ["Group 1", "Group 2", ...],
  "bonding": "Bonding explanation",
  "stereochemistry": "Stereochemistry notes",
  "properties_explained": "How structure affects properties",
  "key_features": ["Feature 1", ...]
}}
"""
            
            response = self.model.generate_content(prompt)
            text = self._clean_json_response(response.text)
            
            result = json.loads(text)
            result['smiles'] = smiles
            result['compound_name'] = compound_name
            
            return result
            
        except Exception as e:
            logger.error(f"Error explaining structure: {e}")
            return {
                "error": str(e),
                "smiles": smiles
            }
    
    def suggest_alternatives(
        self,
        compound_name: str,
        molecular_formula: str,
        current_use: str,
        criteria: str = "safer",
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Suggest alternative compounds.
        
        Args:
            compound_name: Current compound name
            molecular_formula: Current formula
            current_use: How it's being used
            criteria: Selection criteria (safer, cheaper, greener)
            language: Response language
        
        Returns:
            Dictionary with alternative suggestions
        """
        try:
            lang_instruction = (
                "Respond in English." if language == "en"
                else "Respond in Arabic (اللغة العربية)."
            )
            
            prompt = f"""{self.SYSTEM_PROMPT}

CURRENT COMPOUND: {compound_name} ({molecular_formula})
CURRENT USE: {current_use}
CRITERIA: Find {criteria} alternatives

Suggest alternative compounds that are {criteria}:
1. List 3-5 alternatives
2. Explain advantages of each
3. Note any disadvantages
4. Compare cost/safety/environmental impact

{lang_instruction}
Format as JSON:
{{
  "alternatives": [
    {{
      "name": "Alternative compound name",
      "formula": "Chemical formula",
      "advantages": ["Advantage 1", ...],
      "disadvantages": ["Disadvantage 1", ...],
      "cost_comparison": "Cheaper|Similar|More expensive",
      "safety_comparison": "Safer|Similar|Less safe",
      "environmental_impact": "Better|Similar|Worse"
    }}
  ],
  "recommendation": "Best alternative and why",
  "notes": "Additional considerations"
}}
"""
            
            response = self.model.generate_content(prompt)
            text = self._clean_json_response(response.text)
            
            result = json.loads(text)
            result['original_compound'] = compound_name
            result['criteria'] = criteria
            
            return result
            
        except Exception as e:
            logger.error(f"Error suggesting alternatives: {e}")
            return {
                "error": str(e),
                "compound": compound_name
            }

    def analyze_substitution(
        self,
        original: str,
        candidate: str,
        language: str = "en"
    ) -> Dict[str, Any]:
        """
        Analyze substitution of one chemical for another.
        """
        try:
            lang_instruction = (
                "Respond in English." if language == "en"
                else "Respond in Arabic (اللغة العربية)."
            )
            
            prompt = f"""{self.SYSTEM_PROMPT}

ORIGINAL CHEMICAL: {original}
CANDIDATE SUBSTITUTE: {candidate}

Analyze if the candidate is a good substitute for the original chemical.
Consider:
1. Functional similarity (HLB, pH, solubility, etc.)
2. Safety implications (toxicity, flammability, reactivity)
3. Performance impact

{lang_instruction}
Format as JSON:
{{
  "similarity_score": 0.85, // 0.0 to 1.0
  "ai_analysis": "Detailed text analysis...",
  "safety_warning": {{ // Null if safe
    "type": "ALERT_TYPE",
    "hazard_level": "LOW|MEDIUM|HIGH|EXTREME",
    "message": "Warning message",
    "action": "Recommended action"
  }}
}}
"""
            response = self.model.generate_content(prompt)
            text = self._clean_json_response(response.text)
            return json.loads(text)
        except Exception as e:
            logger.error(f"Error analyzing substitution: {e}")
            return {"error": str(e)}
    
    def predict_reaction(
        self,
        reactants: List[str],
        conditions: Optional[Dict[str, Any]] = None,
        language: str = 'en'
    ) -> Dict[str, Any]:
        """
        Predict chemical reaction products and mechanism.
        
        Args:
            reactants: List of reactant SMILES or names
            conditions: Optional reaction conditions (temperature, catalyst, etc.)
            language: Response language ('en' or 'ar')
        
        Returns:
            Dictionary with predicted products, mechanism, and conditions
        """
        try:
            # Build prompt
            lang_instruction = "Respond in Arabic" if language == 'ar' else "Respond in English"
            
            conditions_text = ""
            if conditions:
                conditions_text = f"\n\nReaction Conditions: {json.dumps(conditions, indent=2)}"
            
            prompt = f"""{self.SYSTEM_PROMPT}

{lang_instruction}.

Task: Predict the products and mechanism for the following chemical reaction.

Reactants: {', '.join(reactants)}{conditions_text}

Provide a detailed analysis in the following JSON format:
{{
    "reactants": ["list of reactants"],
    "predicted_products": [
        {{
            "smiles": "product SMILES",
            "name": "product common name",
            "confidence": "high/medium/low"
        }}
    ],
    "reaction_type": "name of reaction type",
    "mechanism": "step-by-step mechanism description",
    "conditions": {{
        "temperature": "recommended temperature range",
        "catalyst": "catalyst if needed",
        "solvent": "solvent if needed",
        "time": "reaction time",
        "yield": "expected yield range"
    }},
    "safety_notes": ["safety precaution 1", "safety precaution 2"],
    "alternative_methods": ["alternative method 1", "alternative method 2"]
}}

IMPORTANT:
- If you cannot predict with confidence, indicate low confidence
- Always include safety notes
- Provide realistic mechanisms based on organic chemistry principles
- Include alternative synthesis methods if applicable
"""
            
            # Generate response
            response = self.model.generate_content(prompt)
            text = response.text.strip()
            
            # Try to extract JSON
            if '```json' in text:
                start = text.find('```json') + 7
                end = text.find('```', start)
                text = text[start:end].strip()
            elif '```' in text:
                start = text.find('```') + 3
                end = text.find('```', start)
                text = text[start:end].strip()
            
            # Parse JSON
            try:
                result = json.loads(text)
                result['raw_response'] = response.text
                return result
            except json.JSONDecodeError:
                # If JSON parsing fails, return structured text
                return {
                    'reactants': reactants,
                    'predicted_products': [],
                    'reaction_type': 'Unknown',
                    'mechanism': text,
                    'conditions': conditions or {},
                    'safety_notes': ['Always use proper PPE', 'Work in fume hood'],
                    'alternative_methods': [],
                    'error': 'Could not parse AI response as JSON',
                    'raw_response': response.text
                }
        
        except Exception as e:
            logger.error(f"Error predicting reaction: {e}")
            return {
                'error': str(e),
                'reactants': reactants,
                'predicted_products': [],
                'reaction_type': 'Error',
                'mechanism': 'Error occurred during prediction',
                'conditions': {},
                'safety_notes': [],
                'alternative_methods': []
            }
    
    def _clean_json_response(self, text: str) -> str:
        """Clean AI response to extract JSON."""
        text = text.strip()
        
        # Remove markdown code blocks
        if text.startswith("```json"):
            text = text[7:]
        elif text.startswith("```"):
            text = text[3:]
        
        if text.endswith("```"):
            text = text[:-3]
        
        return text.strip()


# Singleton instance
_ai_service = None

def get_ai_chemistry_service(api_key: str) -> AIChemistryService:
    """Get or create AI chemistry service instance."""
    global _ai_service
    if _ai_service is None:
        _ai_service = AIChemistryService(api_key)
    return _ai_service
