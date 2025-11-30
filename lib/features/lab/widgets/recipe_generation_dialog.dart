import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../repositories/mix_engine_repository.dart';
import 'variations_carousel.dart';

class RecipeGenerationDialog extends ConsumerStatefulWidget {
  const RecipeGenerationDialog({super.key});

  @override
  ConsumerState<RecipeGenerationDialog> createState() =>
      _RecipeGenerationDialogState();
}

class _RecipeGenerationDialogState
    extends ConsumerState<RecipeGenerationDialog> {
  final _productNameController = TextEditingController();
  final _effectController = TextEditingController();
  bool _isLoading = false;
  List<dynamic>? _variations;

  @override
  void dispose() {
    _productNameController.dispose();
    _effectController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_productNameController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _variations = null;
    });

    try {
      final locale = Localizations.localeOf(context).languageCode;
      final result = await ref
          .read(mixEngineRepositoryProvider)
          .generateVariations(
            productName: _productNameController.text,
            description: _effectController.text,
            language: locale,
          );

      if (mounted) {
        setState(() {
          _variations = result['variations'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.generateVariations,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input Form
            if (_variations == null) ...[
              TextField(
                controller: _productNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.productName,
                  labelStyle: const TextStyle(color: Colors.cyan),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _effectController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: l10n.desiredEffect,
                  labelStyle: const TextStyle(color: Colors.cyan),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generate,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isLoading ? l10n.generating : l10n.startMixing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],

            // Results Carousel
            if (_variations != null)
              Expanded(child: VariationsCarousel(variations: _variations!)),
          ],
        ),
      ),
    );
  }
}
