import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(
    Dio(BaseOptions(baseUrl: 'http://localhost:8000')),
  );
});

class InventoryRepository {
  final Dio _dio;

  InventoryRepository(this._dio);

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    try {
      final response = await _dio.get(
        '/api/inventory/search',
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data;
      return data.map((item) {
        return {
          "id": item['id'].toString(),
          "name": item['name'],
          "category":
              "Chemical", // Default category as backend doesn't have it yet
          "stock": "${item['inventory_level']}kg",
          "price": item['price_per_kg'],
          "cas": item['cas_number'],
        };
      }).toList();
    } catch (e) {
      // Fallback to empty list or rethrow depending on UX needs
      // For now, rethrow to let UI handle error state
      throw Exception('Failed to search inventory: $e');
    }
  }
}
