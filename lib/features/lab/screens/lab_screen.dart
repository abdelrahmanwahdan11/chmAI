import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/adaptive_widgets.dart';
import '../../../core/widgets/rbac_wrapper.dart';
import '../widgets/substitution_dialog.dart';
import '../widgets/recipe_generation_dialog.dart';
import '../../chemistry/screens/periodic_table_screen.dart';
import '../../chemistry/screens/compound_search_screen.dart';
import '../../chemistry/screens/unit_converters_screen.dart';
import '../../chemistry/widgets/calculator_dialogs.dart';
import '../../chemistry/screens/reaction_prediction_screen.dart';

class LabScreen extends ConsumerWidget {
  final void Function(Locale) onLocaleChange;

  const LabScreen({super.key, required this.onLocaleChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    // Mock Recipe Data
    final ingredients = [
      {"name": "Water", "amount": "800g", "hazard": null},
      {"name": "Sodium Lauryl Sulfate", "amount": "150g", "hazard": "Irritant"},
      {
        "name": "Fragrance Oil (Lavender)",
        "amount": "20g",
        "hazard": "Flammable",
      },
      {"name": "Preservative X", "amount": "5g", "hazard": "Toxic"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.science, color: Colors.cyan),
            const SizedBox(width: 12),
            Text(l10n.labTitle),
          ],
        ),
        actions: [
          // START MIXING Button - Now in AppBar!
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const RecipeGenerationDialog(),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 20),
              label: Text(
                l10n.startMixing,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),

          // Language Switcher
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: onLocaleChange,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Locale('en'),
                child: Text(l10n.english),
              ),
              PopupMenuItem(
                value: const Locale('ar'),
                child: Text(l10n.arabic),
              ),
            ],
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, screenSize) {
          // Different layouts based on screen size
          if (screenSize == ScreenSize.mobile) {
            return _buildMobileLayout(context, l10n, ingredients);
          } else if (screenSize == ScreenSize.tablet) {
            return _buildTabletLayout(context, l10n, ingredients);
          } else {
            return _buildDesktopLayout(context, l10n, ingredients);
          }
        },
      ),
    );
  }

  // Mobile Layout - Single Column
  Widget _buildMobileLayout(
    BuildContext context,
    AppLocalizations l10n,
    List<Map<String, dynamic>> ingredients,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildIngredientsPanel(context, l10n, ingredients),
          const Divider(height: 1),
          _buildAIPanel(context, l10n),
        ],
      ),
    );
  }

  // Tablet Layout - Side by Side
  Widget _buildTabletLayout(
    BuildContext context,
    AppLocalizations l10n,
    List<Map<String, dynamic>> ingredients,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildIngredientsPanel(context, l10n, ingredients),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildAIPanel(context, l10n)),
      ],
    );
  }

  // Desktop Layout - Three Columns
  Widget _buildDesktopLayout(
    BuildContext context,
    AppLocalizations l10n,
    List<Map<String, dynamic>> ingredients,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildIngredientsPanel(context, l10n, ingredients),
        ),
        const VerticalDivider(width: 1),
        Expanded(flex: 2, child: _buildAIPanel(context, l10n)),
        const VerticalDivider(width: 1),
        Expanded(flex: 1, child: _buildQuickActionsPanel(context, l10n)),
      ],
    );
  }

  // Ingredients Panel
  Widget _buildIngredientsPanel(
    BuildContext context,
    AppLocalizations l10n,
    List<Map<String, dynamic>> ingredients,
  ) {
    return AdaptiveContainer(
      maxWidth: 800,
      padding: ResponsivePadding.all(
        context,
        mobile: 12,
        tablet: 16,
        desktop: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.cyan, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.activeFormula,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.cyan),
                onPressed: () {},
                tooltip: 'Add Ingredient',
              ),
            ],
          ),

          ResponsiveSpacing.vertical(context, mobile: 12, tablet: 16),

          // Ingredients List
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                final item = ingredients[index];
                return AdaptiveCard(
                  margin: EdgeInsets.only(
                    bottom: context.responsiveValue(
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),
                  onTap: () => _showSwapModal(context, item['name'] as String),
                  child: Row(
                    children: [
                      // Number Badge
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.blue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Name and Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['amount'] as String,
                              style: const TextStyle(
                                color: Colors.cyan,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hazard Badge
                      if (item['hazard'] != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['hazard'] as String,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // More Options
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () =>
                            _showSwapModal(context, item['name'] as String),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Cost Widget (Hidden for Operators)
          RBACWrapper(
            permissionKey: "can_see_cost",
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.totalCost,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "\$45.20",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI Assistant Panel
  Widget _buildAIPanel(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: Colors.black.withOpacity(0.2),
      padding: ResponsivePadding.all(
        context,
        mobile: 12,
        tablet: 16,
        desktop: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.deepPurple.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Colors.purpleAccent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.aiAssistant,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chat Messages
          Expanded(
            child: ListView(
              children: const [
                _AIMessage(
                  text:
                      "I've analyzed the formula. The surfactant ratio looks good for high foam.",
                ),
                _AIMessage(
                  text:
                      "Warning: Adding Fragrance Oil at 50°C might cause evaporation. Cool down to 35°C first.",
                  isWarning: true,
                ),
                _AIMessage(
                  text:
                      "Suggestion: Consider adding Glycerin at 3% for improved moisturization.",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.askGemini,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.cyan),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Panel (Desktop only)
  Widget _buildQuickActionsPanel(BuildContext context, AppLocalizations l10n) {
    return Container(
      color: Colors.black.withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 16),

            // Chemistry Tools
            _buildQuickActionCategory(l10n.chemistry),
            _QuickActionButton(
              icon: Icons.science,
              label: l10n.periodicTable,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PeriodicTableScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.search,
              label: l10n.compoundSearch,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CompoundSearchScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.auto_awesome,
              label: l10n.reactionPrediction,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReactionPredictionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // Calculators
            _buildQuickActionCategory(l10n.calculators),
            _QuickActionButton(
              icon: Icons.science_outlined,
              label: l10n.phCalculator,
              onTap: () {
                ChemistryCalculators.showPHCalculator(context);
              },
            ),
            _QuickActionButton(
              icon: Icons.science_outlined,
              label: l10n.bufferCalculator,
              onTap: () {
                ChemistryCalculators.showBufferCalculator(context);
              },
            ),
            _QuickActionButton(
              icon: Icons.opacity,
              label: l10n.dilutionCalculator,
              onTap: () {
                ChemistryCalculators.showDilutionCalculator(context);
              },
            ),
            _QuickActionButton(
              icon: Icons.calculate,
              label: l10n.molarMass,
              onTap: () {
                ChemistryCalculators.showMolarMassCalculator(context);
              },
            ),
            _QuickActionButton(
              icon: Icons.swap_horiz,
              label: l10n.unitConverters,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UnitConvertersScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),

            // Other Actions
            _buildQuickActionCategory(l10n.other),
            _QuickActionButton(
              icon: Icons.note_add,
              label: l10n.labNotes,
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.history,
              label: l10n.history,
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.bookmark,
              label: l10n.favorites,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white60,
        ),
      ),
    );
  }

  void _showSwapModal(BuildContext context, String ingredientName) {
    showDialog(
      context: context,
      builder: (context) =>
          SubstitutionDialog(originalIngredient: ingredientName),
    );
  }
}

// AI Message Widget
class _AIMessage extends StatelessWidget {
  final String text;
  final bool isWarning;

  const _AIMessage({required this.text, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.orange.withOpacity(0.1)
            : Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? Colors.orange.withOpacity(0.3)
              : Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.auto_awesome,
            color: isWarning ? Colors.orange : Colors.purpleAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isWarning ? Colors.orange[200] : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Action Button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.cyan, size: 20),
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
