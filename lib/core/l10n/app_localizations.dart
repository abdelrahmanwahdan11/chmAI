import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'ChemAI Lab',
      'labTitle': 'Chemical Lab',
      'startMixing': 'START MIXING',
      'activeFormula': 'Active Formula',
      'aiAssistant': 'AI Assistant',
      'askGemini': 'Ask Gemini about reactions...',
      'totalCost': 'Total Cost',
      'quickActions': 'Quick Actions',
      'chemistry': 'Chemistry',
      'calculators': 'Calculators',
      'other': 'Other',
      'periodicTable': 'Periodic Table',
      'compoundSearch': 'Compound Search',
      'reactionPrediction': 'Reaction Prediction',
      'phCalculator': 'pH Calculator',
      'bufferCalculator': 'Buffer Calculator',
      'dilutionCalculator': 'Dilution Calculator',
      'molarMass': 'Molar Mass',
      'unitConverters': 'Unit Converters',
      'labNotes': 'Lab Notes',
      'history': 'History',
      'favorites': 'Favorites',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'generateVariations': 'Generate Recipe Variations',
      'productName': 'Product Name',
      'desiredEffect': 'Desired Effect',
      'generating': 'Generating...',
      'difference': 'Difference',
      'ingredients': 'Ingredients',
      'selectThisRecipe': 'Select This Recipe',
    },
    'ar': {
      'appTitle': 'مختبر ChemAI',
      'labTitle': 'المختبر الكيميائي',
      'startMixing': 'ابدأ الخلط',
      'activeFormula': 'التركيبة النشطة',
      'aiAssistant': 'مساعد الذكاء الاصطناعي',
      'askGemini': 'اسأل Gemini عن التفاعلات...',
      'totalCost': 'التكلفة الإجمالية',
      'quickActions': 'إجراءات سريعة',
      'chemistry': 'الكيمياء',
      'calculators': 'الحاسبات',
      'other': 'أخرى',
      'periodicTable': 'الجدول الدوري',
      'compoundSearch': 'بحث عن مركب',
      'reactionPrediction': 'توقع التفاعل',
      'phCalculator': 'حاسبة pH',
      'bufferCalculator': 'حاسبة المحلول المنظم',
      'dilutionCalculator': 'حاسبة التخفيف',
      'molarMass': 'الكتلة المولية',
      'unitConverters': 'محولات الوحدات',
      'labNotes': 'ملاحظات المختبر',
      'history': 'السجل',
      'favorites': 'المفضلة',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'generateVariations': 'توليد تنويعات الوصفة',
      'productName': 'اسم المنتج',
      'desiredEffect': 'التأثير المطلوب',
      'generating': 'جاري التوليد...',
      'difference': 'الفرق',
      'ingredients': 'المكونات',
      'selectThisRecipe': 'اختر هذه الوصفة',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get labTitle => _localizedValues[locale.languageCode]!['labTitle']!;
  String get startMixing =>
      _localizedValues[locale.languageCode]!['startMixing']!;
  String get activeFormula =>
      _localizedValues[locale.languageCode]!['activeFormula']!;
  String get aiAssistant =>
      _localizedValues[locale.languageCode]!['aiAssistant']!;
  String get askGemini => _localizedValues[locale.languageCode]!['askGemini']!;
  String get totalCost => _localizedValues[locale.languageCode]!['totalCost']!;
  String get quickActions =>
      _localizedValues[locale.languageCode]!['quickActions']!;
  String get chemistry => _localizedValues[locale.languageCode]!['chemistry']!;
  String get calculators =>
      _localizedValues[locale.languageCode]!['calculators']!;
  String get other => _localizedValues[locale.languageCode]!['other']!;
  String get periodicTable =>
      _localizedValues[locale.languageCode]!['periodicTable']!;
  String get compoundSearch =>
      _localizedValues[locale.languageCode]!['compoundSearch']!;
  String get reactionPrediction =>
      _localizedValues[locale.languageCode]!['reactionPrediction']!;
  String get phCalculator =>
      _localizedValues[locale.languageCode]!['phCalculator']!;
  String get bufferCalculator =>
      _localizedValues[locale.languageCode]!['bufferCalculator']!;
  String get dilutionCalculator =>
      _localizedValues[locale.languageCode]!['dilutionCalculator']!;
  String get molarMass => _localizedValues[locale.languageCode]!['molarMass']!;
  String get unitConverters =>
      _localizedValues[locale.languageCode]!['unitConverters']!;
  String get labNotes => _localizedValues[locale.languageCode]!['labNotes']!;
  String get history => _localizedValues[locale.languageCode]!['history']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;

  // New Getters
  String get generateVariations =>
      _localizedValues[locale.languageCode]!['generateVariations']!;
  String get productName =>
      _localizedValues[locale.languageCode]!['productName']!;
  String get desiredEffect =>
      _localizedValues[locale.languageCode]!['desiredEffect']!;
  String get generating =>
      _localizedValues[locale.languageCode]!['generating']!;
  String get difference =>
      _localizedValues[locale.languageCode]!['difference']!;
  String get ingredients =>
      _localizedValues[locale.languageCode]!['ingredients']!;
  String get selectThisRecipe =>
      _localizedValues[locale.languageCode]!['selectThisRecipe']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
