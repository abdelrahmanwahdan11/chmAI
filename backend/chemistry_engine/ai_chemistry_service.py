"""AI Chemistry Service with offline stub implementation."""
from typing import Dict, Any, List, Optional
import json
import logging
from functools import lru_cache
import hashlib

logger = logging.getLogger(__name__)

try:  # pragma: no cover
    import google.generativeai as genai
    GENAI_AVAILABLE = True
except ImportError:  # pragma: no cover
    GENAI_AVAILABLE = False
    genai = None
    logger.warning("google-generativeai not available. Using stub responses.")


class AIChemistryService:
    SYSTEM_PROMPT = "You are an expert chemistry AI assistant."

    def __init__(self, api_key: str | None):
        if GENAI_AVAILABLE:
            if not api_key:
                raise ValueError("Gemini API key is required")
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel('gemini-1.5-flash')
        else:
            self.model = None

    def _create_cache_key(self, *args) -> str:
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
        if not GENAI_AVAILABLE:
            return {
                "analysis": f"Mock analysis for {compound_name} ({molecular_formula})",
                "safety": "Always handle chemicals with care.",
                "language": language,
            }
        prompt = f"Analyze {compound_name} ({molecular_formula})."
        response = self.model.generate_content(prompt)
        return json.loads(response.text)


def get_ai_chemistry_service(api_key: str | None = None) -> AIChemistryService:
    return AIChemistryService(api_key)
