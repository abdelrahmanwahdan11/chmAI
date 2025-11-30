import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/chemistry_service.dart';
import '../widgets/compound_info_dialog.dart';

/// Compound Search Screen
/// Search for chemical compounds by name, formula, CAS, or SMILES
class CompoundSearchScreen extends ConsumerStatefulWidget {
  const CompoundSearchScreen({super.key});

  @override
  ConsumerState<CompoundSearchScreen> createState() =>
      _CompoundSearchScreenState();
}

class _CompoundSearchScreenState extends ConsumerState<CompoundSearchScreen> {
  final _searchController = TextEditingController();
  String _searchType = 'name';
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _results = [];
    });

    try {
      final response = await chemistryService.searchCompounds(
        query: _searchController.text,
        searchType: _searchType,
      );

      setState(() {
        _results = List<Map<String, dynamic>>.from(response['results'] ?? []);
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.search, color: Colors.cyan),
            SizedBox(width: 12),
            Text('Compound Search'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                // Search Type Selector
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _searchType,
                        decoration: const InputDecoration(
                          labelText: 'Search By',
                          labelStyle: TextStyle(color: Colors.cyan),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: const Color(0xFF2E2E2E),
                        items: const [
                          DropdownMenuItem(value: 'name', child: Text('Name')),
                          DropdownMenuItem(
                            value: 'formula',
                            child: Text('Formula'),
                          ),
                          DropdownMenuItem(
                            value: 'smiles',
                            child: Text('SMILES'),
                          ),
                          DropdownMenuItem(
                            value: 'inchi',
                            child: Text('InChI'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _searchType = value!);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _getHintText(),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.cyan,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),

                // Quick examples
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _getExamples().map((example) {
                    return ActionChip(
                      label: Text(example),
                      onPressed: () {
                        _searchController.text = example;
                        _search();
                      },
                      backgroundColor: Colors.white.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? _buildEmptyState()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_searchType) {
      case 'name':
        return 'Enter compound name (e.g., aspirin, water)';
      case 'formula':
        return 'Enter molecular formula (e.g., H2O, C6H12O6)';
      case 'smiles':
        return 'Enter SMILES notation';
      case 'inchi':
        return 'Enter InChI string';
      default:
        return 'Enter search term';
    }
  }

  List<String> _getExamples() {
    switch (_searchType) {
      case 'name':
        return ['Water', 'Aspirin', 'Glucose', 'Ethanol', 'Caffeine'];
      case 'formula':
        return ['H2O', 'C6H12O6', 'CH3COOH', 'C2H5OH', 'NaCl'];
      default:
        return [];
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter a search term above',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by name, formula, SMILES, or InChI',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final compound = _results[index];
        return _buildCompoundCard(compound);
      },
    );
  }

  Widget _buildCompoundCard(Map<String, dynamic> compound) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => CompoundInfoDialog(
              cid: compound['cid'],
              compoundName: compound['name'],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // CID Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'CID',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${compound['cid']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Compound Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compound['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            compound['molecular_formula'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (compound['molecular_weight'] != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${compound['molecular_weight'].toStringAsFixed(2)} g/mol',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (compound['canonical_smiles'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        compound['canonical_smiles'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.arrow_forward_ios, color: Colors.cyan, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
