import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/chemistry_service.dart';
import '../../../core/widgets/adaptive_widgets.dart';

class PeriodicTableScreen extends ConsumerStatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  ConsumerState<PeriodicTableScreen> createState() =>
      _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends ConsumerState<PeriodicTableScreen> {
  List<Map<String, dynamic>> _elements = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPeriodicTable();
  }

  Future<void> _loadPeriodicTable() async {
    try {
      final result = await chemistryService.getPeriodicTable();
      setState(() {
        _elements = List<Map<String, dynamic>>.from(result['elements'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading periodic table: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.science, color: Colors.cyan),
            SizedBox(width: 12),
            Text('Periodic Table'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() => _selectedCategory = category);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All Elements')),
              const PopupMenuItem(
                value: 'alkali_alkaline_earth',
                child: Text('Alkali Metals'),
              ),
              const PopupMenuItem(
                value: 'transition_metal',
                child: Text('Transition Metals'),
              ),
              const PopupMenuItem(value: 'nonmetal', child: Text('Nonmetals')),
              const PopupMenuItem(
                value: 'noble_gas',
                child: Text('Noble Gases'),
              ),
              const PopupMenuItem(value: 'halogen', child: Text('Halogens')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPeriodicTable(),
    );
  }

  Widget _buildPeriodicTable() {
    final filteredElements = _selectedCategory == null
        ? _elements
        : _elements.where((e) => e['category'] == _selectedCategory).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Legend
          _buildLegend(),

          const SizedBox(height: 20),

          // Periodic Table Grid
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate cell size based on screen width
                final cellSize = (constraints.maxWidth / 18).clamp(40.0, 80.0);

                return SizedBox(
                  width: cellSize * 18,
                  child: Wrap(
                    children: _buildElementCells(filteredElements, cellSize),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final categories = {
      'alkali_alkaline_earth': ('Alkali/Alkaline', Color(0xFFFFD700)),
      'transition_metal': ('Transition Metals', Color(0xFFFF6347)),
      'nonmetal': ('Nonmetals', Color(0xFF00FF00)),
      'noble_gas': ('Noble Gases', Color(0xFF00FFFF)),
      'halogen': ('Halogens', Color(0xFFFFFF00)),
      'metalloid': ('Metalloids', Color(0xFFFFA500)),
      'lanthanide': ('Lanthanides', Color(0xFFFF69B4)),
      'actinide': ('Actinides', Color(0xFFFF00FF)),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: categories.entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: entry.value.$2,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white30),
                ),
              ),
              const SizedBox(width: 6),
              Text(entry.value.$1, style: const TextStyle(fontSize: 12)),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildElementCells(
    List<Map<String, dynamic>> elements,
    double cellSize,
  ) {
    final List<Widget> cells = [];

    // Create a map for quick lookup
    final elementMap = {
      for (var e in elements) '${e['period']}-${e['group']}': e,
    };

    // Build 7 periods x 18 groups
    for (int period = 1; period <= 7; period++) {
      for (int group = 1; group <= 18; group++) {
        final key = '$period-$group';
        final element = elementMap[key];

        if (element != null) {
          cells.add(_buildElementCell(element, cellSize));
        } else {
          // Empty cell
          cells.add(SizedBox(width: cellSize, height: cellSize));
        }
      }
    }

    return cells;
  }

  Widget _buildElementCell(Map<String, dynamic> element, double cellSize) {
    final category = element['category'] ?? 'other_metal';
    final color = _getCategoryColor(category);

    return AdaptiveCard(
      margin: EdgeInsets.all(cellSize * 0.02),
      padding: EdgeInsets.all(cellSize * 0.08),
      color: color.withOpacity(0.2),
      onTap: () => _showElementDetails(element),
      child: SizedBox(
        width: cellSize * 0.9,
        height: cellSize * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Atomic number
            Text(
              '${element['atomic_number']}',
              style: TextStyle(
                fontSize: cellSize * 0.15,
                color: Colors.white60,
              ),
            ),

            // Symbol
            Text(
              element['symbol'] ?? '',
              style: TextStyle(
                fontSize: cellSize * 0.25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            // Name
            Text(
              element['name'] ?? '',
              style: TextStyle(
                fontSize: cellSize * 0.12,
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Mass
            Text(
              element['atomic_mass']?.toStringAsFixed(2) ?? '',
              style: TextStyle(fontSize: cellSize * 0.1, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'nonmetal': Color(0xFF00FF00),
      'noble_gas': Color(0xFF00FFFF),
      'halogen': Color(0xFFFFFF00),
      'metalloid': Color(0xFFFFA500),
      'actinide': Color(0xFFFF00FF),
      'lanthanide': Color(0xFFFF69B4),
      'transition_metal': Color(0xFFFF6347),
      'alkali_alkaline_earth': Color(0xFFFFD700),
      'post_transition_metal': Color(0xFFC0C0C0),
      'other_metal': Color(0xFFA9A9A9),
    };
    return colors[category] ?? Colors.grey;
  }

  void _showElementDetails(Map<String, dynamic> element) async {
    try {
      // Fetch full element details
      final details = await chemistryService.getElementInfo(
        element['atomic_number'],
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _ElementDetailsDialog(details: details),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading element details: $e')),
        );
      }
    }
  }
}

class _ElementDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> details;

  const _ElementDetailsDialog({required this.details});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 700,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    details['symbol'] ?? '',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        details['name'] ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Atomic Number: ${details['atomic_number']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection('Basic Properties', [
                      _buildInfoRow(
                        'Atomic Mass',
                        '${details['atomic_mass']} u',
                      ),
                      _buildInfoRow('Group', '${details['group']}'),
                      _buildInfoRow('Period', '${details['period']}'),
                      _buildInfoRow(
                        'Block',
                        '${details['block']?.toUpperCase()}',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildInfoSection('Physical Properties', [
                      _buildInfoRow('Density', '${details['density']} g/cm³'),
                      _buildInfoRow(
                        'Melting Point',
                        '${details['melting_point']} K',
                      ),
                      _buildInfoRow(
                        'Boiling Point',
                        '${details['boiling_point']} K',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    _buildInfoSection('Atomic Properties', [
                      _buildInfoRow(
                        'Electron Configuration',
                        details['electron_configuration'] ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Electronegativity',
                        '${details['electronegativity'] ?? 'N/A'}',
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
