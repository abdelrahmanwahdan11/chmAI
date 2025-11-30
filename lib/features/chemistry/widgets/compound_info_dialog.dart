import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/chemistry_service.dart';
import 'molecule_viewer.dart';
import 'molecule_viewer_3d.dart';
import 'ai_insights_tab.dart';

/// Comprehensive Compound Information Dialog
/// Shows detailed information about a chemical compound
class CompoundInfoDialog extends ConsumerStatefulWidget {
  final int cid;
  final String? compoundName;

  const CompoundInfoDialog({super.key, required this.cid, this.compoundName});

  @override
  ConsumerState<CompoundInfoDialog> createState() => _CompoundInfoDialogState();
}

class _CompoundInfoDialogState extends ConsumerState<CompoundInfoDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _compoundData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadCompoundData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompoundData() async {
    try {
      final data = await chemistryService.getCompoundInfo(widget.cid);
      if (mounted) {
        setState(() {
          _compoundData = data;
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 900,
        height: 700,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.98),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('Error: $_error'))
                  : _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.science, color: Colors.cyan, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.compoundName ??
                      _compoundData?['iupac_name'] ??
                      'Compound CID ${widget.cid}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _compoundData?['molecular_formula'] ?? 'Loading...',
                  style: TextStyle(fontSize: 16, color: Colors.cyan[200]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.cyan,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.cyan,
        isScrollable: true,
        tabs: const [
          Tab(icon: Icon(Icons.info), text: 'Overview'),
          Tab(icon: Icon(Icons.science), text: 'Properties'),
          Tab(icon: Icon(Icons.warning), text: 'Safety'),
          Tab(icon: Icon(Icons.compare_arrows), text: 'Similar'),
          Tab(icon: Icon(Icons.view_in_ar), text: 'Structure'),
          Tab(icon: Icon(Icons.auto_awesome), text: 'AI Insights'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildPropertiesTab(),
        _buildSafetyTab(),
        _buildSimilarTab(),
        _build3DViewTab(),
        _buildAIInsightsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Basic Information', [
            _buildInfoRow('CID', '${widget.cid}'),
            _buildInfoRow('IUPAC Name', _compoundData?['iupac_name'] ?? 'N/A'),
            _buildInfoRow(
              'Molecular Formula',
              _compoundData?['molecular_formula'] ?? 'N/A',
            ),
            _buildInfoRow(
              'Molecular Weight',
              '${_compoundData?['molecular_weight'] ?? 'N/A'} g/mol',
            ),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Identifiers', [
            _buildInfoRow(
              'SMILES',
              _compoundData?['canonical_smiles'] ?? 'N/A',
              monospace: true,
            ),
            _buildInfoRow(
              'InChI',
              _compoundData?['inchi'] ?? 'N/A',
              monospace: true,
            ),
            _buildInfoRow(
              'InChIKey',
              _compoundData?['inchikey'] ?? 'N/A',
              monospace: true,
            ),
            if (_compoundData?['cas_number'] != null)
              _buildInfoRow(
                'CAS Number',
                _compoundData?['cas_number'] ?? 'N/A',
              ),
          ]),
          const SizedBox(height: 24),
          if (_compoundData?['synonyms'] != null &&
              (_compoundData?['synonyms'] as List).isNotEmpty)
            _buildSynonymsSection(),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Computed Properties', [
            _buildInfoRow(
              'Complexity',
              '${_compoundData?['complexity'] ?? 'N/A'}',
            ),
            _buildInfoRow(
              'Heavy Atom Count',
              '${_compoundData?['heavy_atom_count'] ?? 'N/A'}',
            ),
            _buildInfoRow(
              'H-Bond Acceptors',
              '${_compoundData?['h_bond_acceptor_count'] ?? 'N/A'}',
            ),
            _buildInfoRow(
              'H-Bond Donors',
              '${_compoundData?['h_bond_donor_count'] ?? 'N/A'}',
            ),
            _buildInfoRow(
              'Rotatable Bonds',
              '${_compoundData?['rotatable_bond_count'] ?? 'N/A'}',
            ),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Physical Properties', [
            _buildInfoRow(
              'Exact Mass',
              '${_compoundData?['exact_mass'] ?? 'N/A'} g/mol',
            ),
            _buildInfoRow(
              'Monoisotopic Mass',
              '${_compoundData?['monoisotopic_mass'] ?? 'N/A'} g/mol',
            ),
            _buildInfoRow('TPSA', '${_compoundData?['tpsa'] ?? 'N/A'} Ų'),
            _buildInfoRow('XLogP', '${_compoundData?['xlogp'] ?? 'N/A'}'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSafetyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Safety information from PubChem GHS Classification',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoSection('GHS Classification', [
            _buildInfoRow('Signal Word', 'Warning'),
            _buildInfoRow('Hazard Pictograms', 'GHS02, GHS07'),
          ]),
          const SizedBox(height: 24),
          _buildHazardStatements(),
          const SizedBox(height: 24),
          _buildPrecautionaryStatements(),
        ],
      ),
    );
  }

  Widget _buildSimilarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.compare_arrows, size: 64, color: Colors.cyan),
          const SizedBox(height: 16),
          const Text(
            'Similar Compounds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Feature coming soon...',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final similar = await chemistryService.getSimilarCompounds(
                  widget.cid,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Found ${similar['count']} similar compounds',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            icon: const Icon(Icons.search),
            label: const Text('Find Similar Compounds'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewTab() {
    return _StructureViewTab(smiles: _compoundData?['canonical_smiles']);
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool monospace = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontFamily: monospace ? 'monospace' : null,
                fontSize: monospace ? 11 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynonymsSection() {
    final synonyms = _compoundData?['synonyms'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Synonyms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: synonyms
              .take(10)
              .map(
                (syn) => Chip(
                  label: Text(syn.toString()),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHazardStatements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hazard Statements (H-Codes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHazardItem('H225', 'Highly flammable liquid and vapour'),
        _buildHazardItem('H319', 'Causes serious eye irritation'),
      ],
    );
  }

  Widget _buildPrecautionaryStatements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Precautionary Statements (P-Codes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPrecautionItem(
          'P210',
          'Keep away from heat/sparks/open flames/hot surfaces - No smoking',
        ),
        _buildPrecautionItem(
          'P305+P351+P338',
          'IF IN EYES: Rinse cautiously with water for several minutes',
        ),
      ],
    );
  }

  Widget _buildHazardItem(String code, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecautionItem(String code, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsTab() {
    return AIInsightsTabView(
      cid: widget.cid,
      compoundName:
          widget.compoundName ?? _compoundData?['iupac_name'] ?? 'Compound',
      molecularFormula: _compoundData?['molecular_formula'] ?? '',
      smiles: _compoundData?['canonical_smiles'],
      properties: _compoundData ?? {},
    );
  }
}

class _StructureViewTab extends StatefulWidget {
  final String? smiles;

  const _StructureViewTab({this.smiles});

  @override
  State<_StructureViewTab> createState() => _StructureViewTabState();
}

class _StructureViewTabState extends State<_StructureViewTab> {
  Map<String, dynamic>? _structure2DData;
  Map<String, dynamic>? _structure3DData;
  bool _isLoading = true;
  String? _error;
  bool _is3DMode = false;

  @override
  void initState() {
    super.initState();
    _loadStructure();
  }

  Future<void> _loadStructure() async {
    if (widget.smiles == null) {
      setState(() {
        _error = 'No structure data available';
        _isLoading = false;
      });
      return;
    }

    try {
      // Load 2D structure first
      final data2D = await chemistryService.getStructureData(widget.smiles!);

      if (mounted) {
        setState(() {
          _structure2DData = data2D;
          _isLoading = false;
        });
      }

      // Load 3D structure in the background
      try {
        final data3D = await chemistryService.get3DStructure(widget.smiles!);
        if (mounted) {
          setState(() {
            _structure3DData = data3D;
          });
        }
      } catch (e3D) {
        // 3D data is optional, don't show error if it fails
        if (mounted) {
          setState(() {
            _structure3DData = _structure2DData; // Fallback to 2D
          });
        }
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
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.cyan),
            SizedBox(height: 16),
            Text(
              'Loading molecular structure...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading structure',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 2D/3D Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeButton('2D View', !_is3DMode, () {
                  setState(() => _is3DMode = false);
                }),
                const SizedBox(width: 4),
                _buildModeButton('3D View', _is3DMode, () {
                  if (_structure3DData != null) {
                    setState(() => _is3DMode = true);
                  }
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Viewer
          Expanded(
            child: Center(
              child: _is3DMode
                  ? (_structure3DData != null
                        ? MoleculeViewer3D(
                            moleculeData: _structure3DData!,
                            width: 600,
                            height: 500,
                          )
                        : const Text(
                            '3D structure not available',
                            style: TextStyle(color: Colors.white70),
                          ))
                  : MoleculeViewer2D(
                      moleculeData: _structure2DData!,
                      width: 500,
                      height: 500,
                    ),
            ),
          ),
          if (!_is3DMode) const SizedBox(height: 16),
          if (!_is3DMode)
            MoleculeViewerControls(
              onZoomIn: () {}, // TODO: Implement zoom control via state
              onZoomOut: () {},
              onReset: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.cyan.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.cyan : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.cyan : Colors.white70,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
