import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mixEngineRepositoryProvider = Provider<MixEngineRepository>((ref) {
  return MixEngineRepository(
    Dio(BaseOptions(baseUrl: 'http://localhost:8000')),
  );
});

class MixEngineRepository {
  final Dio _dio;

  MixEngineRepository(this._dio);

  /// Calls the Python backend to analyze a chemical substitution.
  ///
  /// Returns a Map containing:
  /// - similarity_score: double (0.0 to 1.0)
  /// - ai_analysis: String (text description)
  /// - safety_warning: Map<String, dynamic>? (if any)
  Future<Map<String, dynamic>> analyzeSubstitution(
    String original,
    String candidate,
  ) async {
    try {
      final response = await _dio.post(
        '/api/chemistry/ai/analyze-substitution',
        data: {
          'original': original,
          'candidate': candidate,
          // 'language': 'ar' // Can be passed dynamically if needed
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to analyze substitution: $e');
    }
  }

  /// Calls the Python backend to generate 6 recipe variations.
  Future<Map<String, dynamic>> generateVariations({
    required String productName,
    required String description,
    required String language,
  }) async {
    try {
      final response = await _dio.post(
        '/generate_variations',
        data: {
          'product_name': productName,
          'description': description,
          'language': language,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to generate variations: $e');
    }
  }
}
