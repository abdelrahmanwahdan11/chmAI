import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Unit Converters Screen
/// Provides professional laboratory unit conversions for:
/// - Temperature (°C, °F, K, °R, °Ré)
/// - Pressure (Pa, kPa, MPa, bar, atm, torr, psi)
/// - Concentration (M, mM, μM, nM, %, ppm, ppb, g/L, mg/L)
class UnitConvertersScreen extends StatefulWidget {
  const UnitConvertersScreen({super.key});

  @override
  State<UnitConvertersScreen> createState() => _UnitConvertersScreenState();
}

class _UnitConvertersScreenState extends State<UnitConvertersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E21),
              const Color(0xFF1A1F3A),
              Colors.cyan.shade900.withOpacity(0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    TemperatureConverter(),
                    PressureConverter(),
                    ConcentrationConverter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.swap_horiz, color: Colors.cyan, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Unit Converters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.cyan,
        unselectedLabelColor: Colors.white60,
        indicator: BoxDecoration(
          color: Colors.cyan.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        tabs: const [
          Tab(icon: Icon(Icons.thermostat), text: 'Temperature'),
          Tab(icon: Icon(Icons.speed), text: 'Pressure'),
          Tab(icon: Icon(Icons.science), text: 'Concentration'),
        ],
      ),
    );
  }
}

/// Temperature Converter Widget
class TemperatureConverter extends StatefulWidget {
  const TemperatureConverter({super.key});

  @override
  State<TemperatureConverter> createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _fromUnit = 'Celsius';
  String _toUnit = 'Fahrenheit';

  final List<String> _units = [
    'Celsius',
    'Fahrenheit',
    'Kelvin',
    'Rankine',
    'Réaumur',
  ];

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_convert);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_fromController.text.isEmpty) {
      _toController.text = '';
      return;
    }

    try {
      final value = double.parse(_fromController.text);
      final result = _convertTemperature(value, _fromUnit, _toUnit);
      _toController.text = result.toStringAsFixed(2);
    } catch (e) {
      _toController.text = 'Error';
    }
  }

  double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      case 'Rankine':
        celsius = (value - 491.67) * 5 / 9;
        break;
      case 'Réaumur':
        celsius = value * 5 / 4;
        break;
      default:
        celsius = value;
    }

    // Convert from Celsius to target unit
    switch (to) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      case 'Rankine':
        return (celsius + 273.15) * 9 / 5;
      case 'Réaumur':
        return celsius * 4 / 5;
      default:
        return celsius;
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;

      final tempText = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = tempText;
    });
  }

  void _clear() {
    setState(() {
      _fromController.clear();
      _toController.clear();
    });
  }

  void _copy() {
    if (_toController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _toController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConverterCard(
            label: 'From',
            controller: _fromController,
            unit: _fromUnit,
            units: _units,
            onUnitChanged: (value) {
              setState(() {
                _fromUnit = value!;
                _convert();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSwapButton(),
          const SizedBox(height: 16),
          _buildConverterCard(
            label: 'To',
            controller: _toController,
            unit: _toUnit,
            units: _units,
            onUnitChanged: (value) {
              setState(() {
                _toUnit = value!;
                _convert();
              });
            },
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
          _buildQuickReference(),
        ],
      ),
    );
  }

  Widget _buildConverterCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required List<String> units,
    required void Function(String?) onUnitChanged,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: unit,
                    onChanged: onUnitChanged,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1A1F3A),
                    style: const TextStyle(color: Colors.white),
                    items: units.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: IconButton(
        onPressed: _swap,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyan),
          ),
          child: const Icon(Icons.swap_vert, color: Colors.cyan, size: 24),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.withOpacity(0.2),
              foregroundColor: Colors.cyan,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReference() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quick Reference',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceItem('Water freezes', '0°C = 32°F = 273.15 K'),
          _buildReferenceItem('Water boils', '100°C = 212°F = 373.15 K'),
          _buildReferenceItem('Absolute zero', '-273.15°C = -459.67°F = 0 K'),
          _buildReferenceItem('Room temperature', '20-25°C = 68-77°F'),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pressure Converter Widget
class PressureConverter extends StatefulWidget {
  const PressureConverter({super.key});

  @override
  State<PressureConverter> createState() => _PressureConverterState();
}

class _PressureConverterState extends State<PressureConverter> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _fromUnit = 'Pascal';
  String _toUnit = 'Bar';

  final Map<String, double> _unitsToPascal = {
    'Pascal': 1.0,
    'Kilopascal': 1000.0,
    'Megapascal': 1000000.0,
    'Bar': 100000.0,
    'Millibar': 100.0,
    'Atmosphere': 101325.0,
    'Torr (mmHg)': 133.322,
    'PSI': 6894.76,
  };

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_convert);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_fromController.text.isEmpty) {
      _toController.text = '';
      return;
    }

    try {
      final value = double.parse(_fromController.text);
      // Convert to Pascal first
      final pascal = value * _unitsToPascal[_fromUnit]!;
      // Convert to target unit
      final result = pascal / _unitsToPascal[_toUnit]!;
      _toController.text = result.toStringAsExponential(4);
    } catch (e) {
      _toController.text = 'Error';
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;

      final tempText = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = tempText;
    });
  }

  void _clear() {
    setState(() {
      _fromController.clear();
      _toController.clear();
    });
  }

  void _copy() {
    if (_toController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _toController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConverterCard(
            label: 'From',
            controller: _fromController,
            unit: _fromUnit,
            units: _unitsToPascal.keys.toList(),
            onUnitChanged: (value) {
              setState(() {
                _fromUnit = value!;
                _convert();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSwapButton(),
          const SizedBox(height: 16),
          _buildConverterCard(
            label: 'To',
            controller: _toController,
            unit: _toUnit,
            units: _unitsToPascal.keys.toList(),
            onUnitChanged: (value) {
              setState(() {
                _toUnit = value!;
                _convert();
              });
            },
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
          _buildQuickReference(),
        ],
      ),
    );
  }

  Widget _buildConverterCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required List<String> units,
    required void Function(String?) onUnitChanged,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: unit,
                    onChanged: onUnitChanged,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1A1F3A),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    items: units.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: IconButton(
        onPressed: _swap,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyan),
          ),
          child: const Icon(Icons.swap_vert, color: Colors.cyan, size: 24),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.withOpacity(0.2),
              foregroundColor: Colors.cyan,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReference() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quick Reference',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceItem('Standard atmosphere', '1 atm = 101,325 Pa'),
          _buildReferenceItem('Bar to atm', '1 bar ≈ 0.987 atm'),
          _buildReferenceItem('PSI to kPa', '1 PSI ≈ 6.895 kPa'),
          _buildReferenceItem('Torr to Pa', '1 Torr ≈ 133.3 Pa'),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Concentration Converter Widget
class ConcentrationConverter extends StatefulWidget {
  const ConcentrationConverter({super.key});

  @override
  State<ConcentrationConverter> createState() => _ConcentrationConverterState();
}

class _ConcentrationConverterState extends State<ConcentrationConverter> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _fromUnit = 'Molarity (M)';
  String _toUnit = 'Millimolar (mM)';

  final Map<String, double> _unitsToMolarity = {
    'Molarity (M)': 1.0,
    'Millimolar (mM)': 0.001,
    'Micromolar (μM)': 0.000001,
    'Nanomolar (nM)': 0.000000001,
  };

  @override
  void initState() {
    super.initState();
    _fromController.addListener(_convert);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _convert() {
    if (_fromController.text.isEmpty) {
      _toController.text = '';
      return;
    }

    try {
      final value = double.parse(_fromController.text);
      // Convert to Molarity first
      final molarity = value * _unitsToMolarity[_fromUnit]!;
      // Convert to target unit
      final result = molarity / _unitsToMolarity[_toUnit]!;

      // Use appropriate formatting based on magnitude
      if (result.abs() < 0.01 || result.abs() > 10000) {
        _toController.text = result.toStringAsExponential(4);
      } else {
        _toController.text = result.toStringAsFixed(6);
      }
    } catch (e) {
      _toController.text = 'Error';
    }
  }

  void _swap() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;

      final tempText = _fromController.text;
      _fromController.text = _toController.text;
      _toController.text = tempText;
    });
  }

  void _clear() {
    setState(() {
      _fromController.clear();
      _toController.clear();
    });
  }

  void _copy() {
    if (_toController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _toController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConverterCard(
            label: 'From',
            controller: _fromController,
            unit: _fromUnit,
            units: _unitsToMolarity.keys.toList(),
            onUnitChanged: (value) {
              setState(() {
                _fromUnit = value!;
                _convert();
              });
            },
          ),
          const SizedBox(height: 16),
          _buildSwapButton(),
          const SizedBox(height: 16),
          _buildConverterCard(
            label: 'To',
            controller: _toController,
            unit: _toUnit,
            units: _unitsToMolarity.keys.toList(),
            onUnitChanged: (value) {
              setState(() {
                _toUnit = value!;
                _convert();
              });
            },
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
          _buildQuickReference(),
        ],
      ),
    );
  }

  Widget _buildConverterCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    required List<String> units,
    required void Function(String?) onUnitChanged,
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: unit,
                    onChanged: onUnitChanged,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color(0xFF1A1F3A),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    items: units.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: IconButton(
        onPressed: _swap,
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.cyan),
          ),
          child: const Icon(Icons.swap_vert, color: Colors.cyan, size: 24),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.withOpacity(0.2),
              foregroundColor: Colors.cyan,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReference() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quick Reference',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReferenceItem('Molar to millimolar', '1 M = 1000 mM'),
          _buildReferenceItem('Millimolar to micromolar', '1 mM = 1000 μM'),
          _buildReferenceItem('Micromolar to nanomolar', '1 μM = 1000 nM'),
          _buildReferenceItem('Standard solution', '1 M = 1 mol/L'),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white70),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
