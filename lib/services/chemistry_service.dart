/// Chemistry Service - Flutter
/// Communicates with chemistry backend for all chemical calculations and data

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ChemistryService {
  final Dio _dio;
  final String baseUrl;

  ChemistryService({String? customBaseUrl})
    : baseUrl = customBaseUrl ?? 'http://localhost:8000',
      _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  // ====================
  // COMPOUND METHODS
  // ====================

  /// Search for compounds by name, formula, SMILES, or CAS number
  Future<Map<String, dynamic>> searchCompounds({
    required String query,
    String searchType = 'name',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/compounds/search',
        data: {'query': query, 'search_type': searchType},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error searching compounds: $e');
      rethrow;
    }
  }

  /// Get detailed compound information by PubChem CID
  Future<Map<String, dynamic>> getCompoundInfo(int cid) async {
    try {
      final response = await _dio.get('$baseUrl/api/chemistry/compounds/$cid');
      return response.data;
    } catch (e) {
      debugPrint('Error fetching compound info: $e');
      rethrow;
    }
  }

  /// Find structurally similar compounds
  Future<Map<String, dynamic>> getSimilarCompounds(
    int cid, {
    double threshold = 90.0,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/chemistry/compounds/$cid/similar',
        queryParameters: {'threshold': threshold},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching similar compounds: $e');
      rethrow;
    }
  }

  /// Get safety and hazard information
  Future<Map<String, dynamic>> getCompoundSafety(int cid) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/chemistry/compounds/$cid/safety',
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching safety info: $e');
      rethrow;
    }
  }

  /// Get known reactions involving a compound
  Future<Map<String, dynamic>> getCompoundReactions(int cid) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/chemistry/compounds/$cid/reactions',
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching reactions: $e');
      rethrow;
    }
  }

  /// Get 2D structure data for visualization
  Future<Map<String, dynamic>> getStructureData(String smiles) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/structure/data',
        data: {'smiles': smiles},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching structure data: $e');
      rethrow;
    }
  }

  /// Get 3D structure coordinates
  Future<Map<String, dynamic>> get3DStructure(String smiles) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/structure/3d',
        data: {'smiles': smiles},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching 3D structure: $e');
      rethrow;
    }
  }

  /// Calculate molecular descriptors
  Future<Map<String, dynamic>> calculateDescriptors(String smiles) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/structure/descriptors',
        data: {'smiles': smiles},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating descriptors: $e');
      rethrow;
    }
  }

  /// Get structure image URL
  String getStructureImageUrl(String smiles) {
    return '$baseUrl/api/chemistry/structure/image?smiles=${Uri.encodeComponent(smiles)}';
  }

  // ====================
  // PERIODIC TABLE METHODS
  // ====================

  /// Get the complete periodic table
  Future<Map<String, dynamic>> getPeriodicTable() async {
    try {
      final response = await _dio.get('$baseUrl/api/chemistry/periodic-table');
      return response.data;
    } catch (e) {
      debugPrint('Error fetching periodic table: $e');
      rethrow;
    }
  }

  /// Get element information by symbol or atomic number
  Future<Map<String, dynamic>> getElementInfo(dynamic identifier) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/periodic-table/element',
        data: {'identifier': identifier},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching element info: $e');
      rethrow;
    }
  }

  /// Search for elements matching criteria
  Future<Map<String, dynamic>> searchElements(
    Map<String, dynamic> criteria,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/periodic-table/search',
        data: criteria,
      );
      return response.data;
    } catch (e) {
      debugPrint('Error searching elements: $e');
      rethrow;
    }
  }

  /// Get isotope information for an element
  Future<Map<String, dynamic>> getElementIsotopes(String symbol) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/chemistry/periodic-table/element/$symbol/isotopes',
      );
      return response.data;
    } catch (e) {
      debugPrint('Error fetching isotopes: $e');
      rethrow;
    }
  }

  // ====================
  // REACTION & CALCULATION METHODS
  // ====================

  /// Balance a chemical equation
  Future<Map<String, dynamic>> balanceEquation(String equation) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/reactions/balance',
        data: {'equation': equation},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error balancing equation: $e');
      rethrow;
    }
  }

  /// Calculate stoichiometric amounts
  Future<Map<String, dynamic>> calculateStoichiometry({
    required String equation,
    required String givenSubstance,
    required double givenAmount,
    required String targetSubstance,
    String unit = 'mol',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/reactions/stoichiometry',
        data: {
          'equation': equation,
          'given_substance': givenSubstance,
          'given_amount': givenAmount,
          'target_substance': targetSubstance,
          'unit': unit,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating stoichiometry: $e');
      rethrow;
    }
  }

  /// Calculate pH of a solution
  Future<Map<String, dynamic>> calculatePH({
    required double concentration,
    required String substanceType,
    double? pka,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/calculations/ph',
        data: {
          'concentration': concentration,
          'substance_type': substanceType,
          if (pka != null) 'pka': pka,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating pH: $e');
      rethrow;
    }
  }

  /// Calculate buffer solution composition
  Future<Map<String, dynamic>> calculateBuffer({
    required double targetPH,
    required double pka,
    double totalConcentration = 0.1,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/calculations/buffer',
        data: {
          'target_ph': targetPH,
          'pka': pka,
          'total_concentration': totalConcentration,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating buffer: $e');
      rethrow;
    }
  }

  /// Calculate dilution parameters
  Future<Map<String, dynamic>> calculateDilution({
    required double initialConcentration,
    required double initialVolume,
    double? finalConcentration,
    double? finalVolume,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/calculations/dilution',
        data: {
          'initial_concentration': initialConcentration,
          'initial_volume': initialVolume,
          if (finalConcentration != null)
            'final_concentration': finalConcentration,
          if (finalVolume != null) 'final_volume': finalVolume,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating dilution: $e');
      rethrow;
    }
  }

  /// Calculate molar mass from chemical formula
  Future<Map<String, dynamic>> calculateMolarMass(String formula) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/calculations/molar-mass',
        queryParameters: {'formula': formula},
      );
      return response.data;
    } catch (e) {
      debugPrint('Error calculating molar mass: $e');
      rethrow;
    }
  }

  // ====================
  // AI CHEMISTRY ANALYSIS METHODS
  // ====================

  /// Analyze compound using AI
  Future<Map<String, dynamic>> analyzeCompoundAI({
    required int cid,
    required String compoundName,
    required String molecularFormula,
    String? smiles,
    Map<String, dynamic>? properties,
    String analysisType = 'general',
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/ai/analyze-compound',
        data: {
          'cid': cid,
          'compound_name': compoundName,
          'molecular_formula': molecularFormula,
          'smiles': smiles,
          'properties': properties ?? {},
          'analysis_type': analysisType,
          'language': language,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error analyzing compound with AI: $e');
      rethrow;
    }
  }

  /// Predict chemical reaction using AI
  Future<Map<String, dynamic>> predictReaction({
    required List<String> reactants,
    Map<String, dynamic>? conditions,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/ai/predict-reaction',
        data: {
          'reactants': reactants,
          'conditions': conditions,
          'language': language,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error predicting reaction: $e');
      rethrow;
    }
  }

  /// Explain molecular structure using AI
  Future<Map<String, dynamic>> explainStructure({
    required String smiles,
    String? compoundName,
    String focus = 'general',
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/ai/explain-structure',
        data: {
          'smiles': smiles,
          'compound_name': compoundName,
          'focus': focus,
          'language': language,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error explaining structure: $e');
      rethrow;
    }
  }

  /// Suggest alternative compounds using AI
  Future<Map<String, dynamic>> suggestAlternatives({
    required String compoundName,
    required String molecularFormula,
    required String currentUse,
    String criteria = 'safer',
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/chemistry/ai/suggest-alternatives',
        data: {
          'compound_name': compoundName,
          'molecular_formula': molecularFormula,
          'current_use': currentUse,
          'criteria': criteria,
          'language': language,
        },
      );
      return response.data;
    } catch (e) {
      debugPrint('Error suggesting alternatives: $e');
      rethrow;
    }
  }
}

// Singleton instance
final chemistryService = ChemistryService();
