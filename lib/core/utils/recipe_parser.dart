class IngredientItem {
  final String name;
  final double amount;
  final String unit;
  final bool isUpTo;

  IngredientItem({
    required this.name,
    required this.amount,
    this.unit = '%',
    this.isUpTo = false,
  });

  @override
  String toString() => '$name: ${isUpTo ? "up to " : ""}$amount$unit';
}

class RecipeParser {
  /// Parses a raw recipe string into a list of [IngredientItem]s.
  ///
  /// Expected format per line: "Ingredient Name AmountUnit"
  /// Examples:
  /// - "Water up to 100%"
  /// - "EDTA 0.1%"
  /// - "SLES 15%"
  static List<IngredientItem> parse(String rawRecipe) {
    final List<IngredientItem> ingredients = [];
    final lines = rawRecipe.split('\n');

    // Regex to capture:
    // Group 1: Name (lazy match until the number)
    // Group 2: "up to" (optional)
    // Group 3: Amount (number, int or float)
    // Group 4: Unit (optional, e.g., %, g, kg)
    final regex = RegExp(
      r'^(.+?)\s+(up\s+to\s+)?(\d+(?:\.\d+)?)\s*(%|g|kg|ml|l)?$',
      caseSensitive: false,
      multiLine: false,
    );

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final match = regex.firstMatch(line);
      if (match != null) {
        final name = match.group(1)?.trim() ?? "Unknown";
        final isUpTo = match.group(2) != null;
        final amountStr = match.group(3);
        final unit = match.group(4) ?? '%';

        if (amountStr != null) {
          final amount = double.tryParse(amountStr) ?? 0.0;
          ingredients.add(
            IngredientItem(
              name: name,
              amount: amount,
              unit: unit,
              isUpTo: isUpTo,
            ),
          );
        }
      } else {
        // Fallback for lines that don't match perfectly but might be valid
        // For now, we just log or skip.
        // Could implement a simpler fallback split by space if needed.
        print("Failed to parse line: $line");
      }
    }

    return ingredients;
  }
}
