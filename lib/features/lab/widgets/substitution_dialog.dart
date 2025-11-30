import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/mix_engine_repository.dart';
import '../../inventory/repositories/inventory_repository.dart';

class SubstitutionDialog extends ConsumerStatefulWidget {
  final String originalIngredient;

  const SubstitutionDialog({super.key, required this.originalIngredient});

  @override
  ConsumerState<SubstitutionDialog> createState() => _SubstitutionDialogState();
}

class _SubstitutionDialogState extends ConsumerState<SubstitutionDialog> {
  String? _selectedCandidate;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.length > 2) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    final results = await ref
        .read(inventoryRepositoryProvider)
        .searchIngredients(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  Future<void> _analyze(String candidate) async {
    setState(() {
      _selectedCandidate = candidate;
      _isLoading = true;
      _analysisResult = null;
      _searchResults = []; // Clear search to focus on result
    });

    try {
      final result = await ref
          .read(mixEngineRepositoryProvider)
          .analyzeSubstitution(widget.originalIngredient, candidate);
      if (mounted) {
        setState(() {
          _analysisResult = result;
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Substitute ${widget.originalIngredient}",
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

                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search inventory...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Search Results
                if (_searchResults.isNotEmpty && _selectedCandidate == null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Stock: ${item['stock']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.cyan,
                          ),
                          onTap: () => _analyze(item['name']),
                        );
                      },
                    ),
                  ),

                // Loading State
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  ),

                // Analysis Result
                if (_analysisResult != null) ...[
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Similarity Score
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  value:
                                      _analysisResult!['similarity_score']
                                          as double,
                                  strokeWidth: 10,
                                  backgroundColor: Colors.white10,
                                  color:
                                      (_analysisResult!['similarity_score']
                                              as double) <
                                          0.5
                                      ? Colors.red
                                      : Colors.cyan,
                                ),
                              ),
                              Text(
                                "${((_analysisResult!['similarity_score'] as double) * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Similarity Score",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 20),

                          // AI Analysis Text
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _analysisResult!['safety_warning'] != null
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.cyan.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _analysisResult!['safety_warning'] != null
                                          ? Icons.warning_amber_rounded
                                          : Icons.auto_awesome,
                                      color:
                                          _analysisResult!['safety_warning'] !=
                                              null
                                          ? Colors.red
                                          : Colors.purpleAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "AI Analysis",
                                      style: TextStyle(
                                        color:
                                            _analysisResult!['safety_warning'] !=
                                                null
                                            ? Colors.red
                                            : Colors.purpleAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _analysisResult!['ai_analysis'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCandidate = null;
                            _analysisResult = null;
                            _searchController.clear();
                          });
                        },
                        child: const Text("Back"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _analysisResult!['safety_warning'] != null
                            ? null // Disable if dangerous
                            : () {
                                // Apply substitution logic here
                                Navigator.of(context).pop(_selectedCandidate);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Apply Substitution"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
