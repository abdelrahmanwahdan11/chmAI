import 'package:flutter/material.dart';

/// Simple localization class without code generation
class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings)!;
  }

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  // Lab Screen Strings
  String get labTitle =>
      locale.languageCode == 'ar' ? 'المختبر الكيميائي' : 'Chemical Lab';

  String get activeFormula =>
      locale.languageCode == 'ar' ? 'الوصفة النشطة' : 'Active Formula';

  String get totalCost =>
      locale.languageCode == 'ar' ? 'التكلفة الإجمالية' : 'Total Cost';

  String get aiAssistant =>
      locale.languageCode == 'ar' ? 'المساعد الذكي' : 'AI Assistant';

  String get askGemini =>
      locale.languageCode == 'ar' ? 'اسأل Gemini...' : 'Ask Gemini...';

  String get startMixing =>
      locale.languageCode == 'ar' ? 'ابدأ المزج' : 'START MIXING';

  // Recipe Generation Dialog Strings
  String get generateVariations => locale.languageCode == 'ar'
      ? 'توليد تنويعات الوصفة'
      : 'Generate Recipe Variations';

  String get productName =>
      locale.languageCode == 'ar' ? 'اسم المنتج' : 'Product Name';

  String get desiredEffect =>
      locale.languageCode == 'ar' ? 'التأثير المطلوب' : 'Desired Effect';

  String get generating =>
      locale.languageCode == 'ar' ? 'جاري التوليد...' : 'Generating...';

  // Variations Carousel Strings
  String get difference => locale.languageCode == 'ar' ? 'الفرق' : 'Difference';

  String get ingredients =>
      locale.languageCode == 'ar' ? 'المكونات' : 'Ingredients';

  String get selectThisRecipe =>
      locale.languageCode == 'ar' ? 'اختر هذه الوصفة' : 'Select This Recipe';
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) async {
    return AppStrings(locale);
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
