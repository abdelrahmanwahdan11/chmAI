import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/chemistry_service.dart';

/// Collection of chemistry calculator dialogs
class ChemistryCalculators {
  static void showPHCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PHCalculatorDialog(),
    );
  }

  static void showBufferCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const BufferCalculatorDialog(),
    );
  }

  static void showDilutionCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DilutionCalculatorDialog(),
    );
  }

  static void showMolarMassCalculator(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const MolarMassCalculatorDialog(),
    );
  }
}

/// pH Calculator Dialog
class PHCalculatorDialog extends ConsumerStatefulWidget {
  const PHCalculatorDialog({super.key});

  @override
  ConsumerState<PHCalculatorDialog> createState() => _PHCalculatorDialogState();
}

class _PHCalculatorDialogState extends ConsumerState<PHCalculatorDialog> {
  final _concentrationController = TextEditingController();
  final _pkaController = TextEditingController();
  String _substanceType = 'strong_acid';
  Map<String, dynamic>? _result;
  bool _isCalculating = false;

  @override
  void dispose() {
    _concentrationController.dispose();
    _pkaController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_concentrationController.text.isEmpty) return;

    setState(() => _isCalculating = true);

    try {
      final result = await chemistryService.calculatePH(
        concentration: double.parse(_concentrationController.text),
        substanceType: _substanceType,
        pka: _pkaController.text.isNotEmpty
            ? double.parse(_pkaController.text)
            : null,
      );

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
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
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.science, color: Colors.cyan, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'pH Calculator',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Substance Type Selector
            DropdownButtonFormField<String>(
              value: _substanceType,
              decoration: const InputDecoration(
                labelText: 'Substance Type',
                labelStyle: TextStyle(color: Colors.cyan),
                border: OutlineInputBorder(),
              ),
              dropdownColor: const Color(0xFF2E2E2E),
              items: const [
                DropdownMenuItem(
                  value: 'strong_acid',
                  child: Text('Strong Acid'),
                ),
                DropdownMenuItem(
                  value: 'strong_base',
                  child: Text('Strong Base'),
                ),
                DropdownMenuItem(value: 'weak_acid', child: Text('Weak Acid')),
                DropdownMenuItem(value: 'weak_base', child: Text('Weak Base')),
              ],
              onChanged: (value) {
                setState(() => _substanceType = value!);
              },
            ),

            const SizedBox(height: 16),

            // Concentration Input
            TextField(
              controller: _concentrationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Concentration (M)',
                labelStyle: TextStyle(color: Colors.cyan),
                suffixText: 'mol/L',
                suffixStyle: TextStyle(color: Colors.white60),
                border: OutlineInputBorder(),
              ),
            ),

            if (_substanceType.contains('weak')) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _pkaController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'pKa',
                  labelStyle: TextStyle(color: Colors.cyan),
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCalculating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Calculate pH'),
              ),
            ),

            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final ph = _result!['ph'];
    final poh = _result!['poh'];
    final isAcidic = _result!['is_acidic'];
    final isBasic = _result!['is_basic'];

    Color resultColor = Colors.green;
    String classification = 'Neutral';
    if (isAcidic) {
      resultColor = Colors.red;
      classification = 'Acidic';
    } else if (isBasic) {
      resultColor = Colors.blue;
      classification = 'Basic';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resultColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // pH Value - Large Display
          Text('pH', style: TextStyle(color: resultColor, fontSize: 16)),
          Text(
            '$ph',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),
          const SizedBox(height: 16),

          // Classification
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              classification.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Additional Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResultItem('pH', '$ph'),
              _buildResultItem('pOH', '$poh'),
              _buildResultItem('[H⁺]', '${_concentrationController.text} M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Buffer Calculator Dialog
class BufferCalculatorDialog extends ConsumerStatefulWidget {
  const BufferCalculatorDialog({super.key});

  @override
  ConsumerState<BufferCalculatorDialog> createState() =>
      _BufferCalculatorDialogState();
}

class _BufferCalculatorDialogState
    extends ConsumerState<BufferCalculatorDialog> {
  final _targetPHController = TextEditingController();
  final _pkaController = TextEditingController();
  final _totalConcentrationController = TextEditingController(text: '0.1');
  Map<String, dynamic>? _result;
  bool _isCalculating = false;

  @override
  void dispose() {
    _targetPHController.dispose();
    _pkaController.dispose();
    _totalConcentrationController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_targetPHController.text.isEmpty || _pkaController.text.isEmpty) return;

    setState(() => _isCalculating = true);

    try {
      final result = await chemistryService.calculateBuffer(
        targetPH: double.parse(_targetPHController.text),
        pka: double.parse(_pkaController.text),
        totalConcentration: double.parse(_totalConcentrationController.text),
      );

      setState(() {
        _result = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() => _isCalculating = false);
      if (mounted) {
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
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.science, color: Colors.cyan, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Buffer Calculator',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _targetPHController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target pH',
                labelStyle: TextStyle(color: Colors.cyan),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _pkaController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'pKa of Acid',
                labelStyle: TextStyle(color: Colors.cyan),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _totalConcentrationController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Total Concentration',
                labelStyle: TextStyle(color: Colors.cyan),
                suffixText: 'M',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCalculating ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCalculating
                    ? const CircularProgressIndicator()
                    : const Text('Calculate Buffer'),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildBufferResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBufferResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buffer Composition',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          _buildBufferResultRow(
            'Acid Concentration',
            '${_result!['acid_concentration']} M',
          ),
          _buildBufferResultRow(
            'Base Concentration',
            '${_result!['base_concentration']} M',
          ),
          _buildBufferResultRow(
            'Acid/Base Ratio',
            '${_result!['acid_base_ratio']}',
          ),
          _buildBufferResultRow(
            'Buffer Capacity',
            '${_result!['buffer_capacity']}',
          ),
        ],
      ),
    );
  }

  Widget _buildBufferResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dilution Calculator Dialog
class DilutionCalculatorDialog extends ConsumerStatefulWidget {
  const DilutionCalculatorDialog({super.key});

  @override
  ConsumerState<DilutionCalculatorDialog> createState() =>
      _DilutionCalculatorDialogState();
}

class _DilutionCalculatorDialogState
    extends ConsumerState<DilutionCalculatorDialog> {
  final _c1Controller = TextEditingController();
  final _v1Controller = TextEditingController();
  final _c2Controller = TextEditingController();
  final _v2Controller = TextEditingController();
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _c1Controller.dispose();
    _v1Controller.dispose();
    _c2Controller.dispose();
    _v2Controller.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_c1Controller.text.isEmpty || _v1Controller.text.isEmpty) return;
    if (_c2Controller.text.isEmpty && _v2Controller.text.isEmpty) return;

    try {
      final result = await chemistryService.calculateDilution(
        initialConcentration: double.parse(_c1Controller.text),
        initialVolume: double.parse(_v1Controller.text),
        finalConcentration: _c2Controller.text.isNotEmpty
            ? double.parse(_c2Controller.text)
            : null,
        finalVolume: _v2Controller.text.isNotEmpty
            ? double.parse(_v2Controller.text)
            : null,
      );

      setState(() => _result = result);
    } catch (e) {
      if (mounted) {
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
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.opacity, color: Colors.cyan, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Dilution Calculator',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'C₁V₁ = C₂V₂',
              style: TextStyle(
                fontSize: 20,
                color: Colors.cyan,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c1Controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'C₁',
                      labelStyle: TextStyle(color: Colors.cyan),
                      suffixText: 'M',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _v1Controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'V₁',
                      labelStyle: TextStyle(color: Colors.cyan),
                      suffixText: 'mL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c2Controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'C₂ (optional)',
                      labelStyle: TextStyle(color: Colors.cyan),
                      suffixText: 'M',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _v2Controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'V₂ (optional)',
                      labelStyle: TextStyle(color: Colors.cyan),
                      suffixText: 'mL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Calculate'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildDilutionResultRow(
                      'Final Concentration',
                      '${_result!['final_concentration']} M',
                    ),
                    _buildDilutionResultRow(
                      'Final Volume',
                      '${_result!['final_volume']} mL',
                    ),
                    const Divider(color: Colors.white24),
                    _buildDilutionResultRow(
                      'Solvent to Add',
                      '${_result!['solvent_to_add']} mL',
                      highlight: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDilutionResultRow(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight ? Colors.green : Colors.white70,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Molar Mass Calculator Dialog
class MolarMassCalculatorDialog extends ConsumerStatefulWidget {
  const MolarMassCalculatorDialog({super.key});

  @override
  ConsumerState<MolarMassCalculatorDialog> createState() =>
      _MolarMassCalculatorDialogState();
}

class _MolarMassCalculatorDialogState
    extends ConsumerState<MolarMassCalculatorDialog> {
  final _formulaController = TextEditingController();
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_formulaController.text.isEmpty) return;

    try {
      final result = await chemistryService.calculateMolarMass(
        _formulaController.text,
      );
      setState(() => _result = result);
    } catch (e) {
      if (mounted) {
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
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.cyan, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Molar Mass',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _formulaController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Chemical Formula',
                labelStyle: TextStyle(color: Colors.cyan),
                hintText: 'e.g., H2O, C6H12O6',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Calculate'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      _result!['formula'],
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_result!['molar_mass']}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Text(
                      'g/mol',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
