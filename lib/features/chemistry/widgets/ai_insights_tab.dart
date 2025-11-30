import 'package:flutter/material.dart';
import '../../../services/chemistry_service.dart';

/// AI Insights Tab - Shows AI-powered analysis
class AIInsightsTabView extends StatefulWidget {
  final int cid;
  final String compoundName;
  final String molecularFormula;
  final String? smiles;
  final Map<String, dynamic> properties;

  const AIInsightsTabView({
    super.key,
    required this.cid,
    required this.compoundName,
    required this.molecularFormula,
    this.smiles,
    required this.properties,
  });

  @override
  State<AIInsightsTabView> createState() => _AIInsightsTabViewState();
}

class _AIInsightsTabViewState extends State<AIInsightsTabView> {
  String _selectedAnalysis = 'general';
  String _selectedLanguage = 'en';
  Map<String, dynamic>? _analysisData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAIAnalysis();
  }

  Future<void> _loadAIAnalysis() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await chemistryService.analyzeCompoundAI(
        cid: widget.cid,
        compoundName: widget.compoundName,
        molecularFormula: widget.molecularFormula,
        smiles: widget.smiles,
        properties: widget.properties,
        analysisType: _selectedAnalysis,
        language: _selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _analysisData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControls(),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.cyan),
                      SizedBox(height: 16),
                      Text(
                        'AI is analyzing the compound...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : _error != null
              ? _buildError()
              : _buildAnalysisContent(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis Type Selector
          const Text(
            'Analysis Type:',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('general', 'General', Icons.info),
              _buildTypeChip('safety', 'Safety', Icons.warning),
              _buildTypeChip('applications', 'Applications', Icons.work),
              _buildTypeChip('synthesis', 'Synthesis', Icons.science),
            ],
          ),
          const SizedBox(height: 16),
          // Language Toggle
          Row(
            children: [
              const Text(
                'Language:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              _buildLanguageButton('en', 'English'),
              const SizedBox(width: 8),
              _buildLanguageButton('ar', 'العربية'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final isSelected = _selectedAnalysis == type;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.cyan),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected && _selectedAnalysis != type) {
          setState(() {
            _selectedAnalysis = type;
          });
          _loadAIAnalysis();
        }
      },
      selectedColor: Colors.cyan.withOpacity(0.4),
      backgroundColor: Colors.black.withOpacity(0.3),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.cyan),
      side: BorderSide(
        color: isSelected ? Colors.cyan : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLanguageButton(String lang, String label) {
    final isSelected = _selectedLanguage == lang;
    return InkWell(
      onTap: () {
        if (_selectedLanguage != lang) {
          setState(() {
            _selectedLanguage = lang;
          });
          _loadAIAnalysis();
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.cyan : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'AI Analysis Unavailable',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAIAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    if (_analysisData == null || _analysisData!['error'] != null) {
      return _buildError();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.cyan,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.compoundName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Content based on analysis type
          if (_selectedAnalysis == 'general') ..._buildGeneralAnalysis(),
          if (_selectedAnalysis == 'safety') ..._buildSafetyAnalysis(),
          if (_selectedAnalysis == 'applications')
            ..._buildApplicationsAnalysis(),
          if (_selectedAnalysis == 'synthesis') ..._buildSynthesisAnalysis(),
        ],
      ),
    );
  }

  List<Widget> _buildGeneralAnalysis() {
    return [
      if (_analysisData?['overview'] != null) ...[
        _buildSection('Overview', Icons.info),
        _buildContentBox(_analysisData!['overview']),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['properties'] != null) ...[
        _buildSection('Key Properties', Icons.science),
        ..._buildListItems(_analysisData!['properties'], Colors.cyan),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['applications'] != null) ...[
        _buildSection('Common Uses', Icons.work),
        ..._buildListItems(_analysisData!['applications'], Colors.blue),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['facts'] != null) ...[
        _buildSection('Interesting Facts', Icons.lightbulb),
        ..._buildListItems(_analysisData!['facts'], Colors.amber),
      ],
    ];
  }

  List<Widget> _buildSafetyAnalysis() {
    return [
      if (_analysisData?['hazard_level'] != null) ...[
        _buildHazardLevel(_analysisData!['hazard_level']),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['hazards'] != null) ...[
        _buildSection('Hazards', Icons.warning),
        ..._buildListItems(_analysisData!['hazards'], Colors.red),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['precautions'] != null) ...[
        _buildSection('Handling Precautions', Icons.pan_tool),
        ..._buildListItems(_analysisData!['precautions'], Colors.orange),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['storage'] != null) ...[
        _buildSection('Storage Requirements', Icons.inventory),
        _buildContentBox(_analysisData!['storage']),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['ppe'] != null) ...[
        _buildSection('Personal Protective Equipment', Icons.health_and_safety),
        ..._buildListItems(_analysisData!['ppe'], Colors.green),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['first_aid'] != null) ...[
        _buildSection('First Aid', Icons.local_hospital),
        _buildContentBox(_analysisData!['first_aid']),
      ],
    ];
  }

  List<Widget> _buildApplicationsAnalysis() {
    return [
      if (_analysisData?['industrial'] != null) ...[
        _buildSection('Industrial Uses', Icons.factory),
        ..._buildListItems(_analysisData!['industrial'], Colors.cyan),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['laboratory'] != null) ...[
        _buildSection('Laboratory Applications', Icons.biotech),
        ..._buildListItems(_analysisData!['laboratory'], Colors.purple),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['consumer'] != null) ...[
        _buildSection('Consumer Products', Icons.shopping_cart),
        ..._buildListItems(_analysisData!['consumer'], Colors.blue),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['research'] != null) ...[
        _buildSection('Research Applications', Icons.science_outlined),
        ..._buildListItems(_analysisData!['research'], Colors.teal),
        const SizedBox(height: 20),
      ],
      if (_analysisData?['emerging'] != null) ...[
        _buildSection('Emerging Uses', Icons.new_releases),
        ..._buildListItems(_analysisData!['emerging'], Colors.amber),
      ],
    ];
  }

  List<Widget> _buildSynthesisAnalysis() {
    final methods = _analysisData?['methods'] as List?;
    if (methods == null || methods.isEmpty) {
      return [
        const Text(
          'No synthesis methods available',
          style: TextStyle(color: Colors.white70),
        ),
      ];
    }

    return methods.map((method) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildMethodCard(method), const SizedBox(height: 16)],
      );
    }).toList();
  }

  Widget _buildSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBox(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        content,
        style: const TextStyle(color: Colors.white, height: 1.5),
      ),
    );
  }

  List<Widget> _buildListItems(dynamic items, Color color) {
    if (items is! List) return [];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.toString(),
                style: const TextStyle(color: Colors.white, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildHazardLevel(String level) {
    Color color;
    IconData icon;
    switch (level.toLowerCase()) {
      case 'low':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'moderate':
        color = Colors.orange;
        icon = Icons.warning_amber;
        break;
      case 'high':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'severe':
        color = Colors.deepPurple;
        icon = Icons.dangerous;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hazard Level',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  level.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  method['name'] ?? 'Synthesis Method',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
              ),
              if (method['type'] != null)
                Chip(
                  label: Text(method['type']),
                  backgroundColor: Colors.cyan.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.cyan, fontSize: 11),
                ),
            ],
          ),
          if (method['difficulty'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${method['difficulty']}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          if (method['starting_materials'] != null) ...[
            const SizedBox(height: 12),
            const Text(
              'Starting Materials:',
              style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ..._buildListItems(method['starting_materials'], Colors.blue),
          ],
          if (method['steps'] != null) ...[
            const SizedBox(height: 12),
            const Text(
              'Steps:',
              style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ..._buildListItems(method['steps'], Colors.green),
          ],
        ],
      ),
    );
  }
}
