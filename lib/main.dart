import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/lab/screens/lab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found or failed to load: $e");
  }

  runApp(const ProviderScope(child: ChemAIApp()));
}

class ChemAIApp extends ConsumerStatefulWidget {
  const ChemAIApp({super.key});

  @override
  ConsumerState<ChemAIApp> createState() => _ChemAIAppState();
}

class _ChemAIAppState extends ConsumerState<ChemAIApp> {
  Locale _locale = const Locale('ar'); // Default to Arabic

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isAuthenticated = ref.read(authProvider).isAuthenticated;
        final isGoingToLogin = state.matchedLocation == '/login';

        // If not authenticated and not going to login, redirect to login
        if (!isAuthenticated && !isGoingToLogin) {
          return '/login';
        }

        // If authenticated and going to login, redirect to lab
        if (isAuthenticated && isGoingToLogin) {
          return '/lab';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/lab',
          builder: (context, state) => LabScreen(onLocaleChange: _changeLocale),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChemAI Industrial OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkIndustrial,

      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],

      // Router
      routerConfig: _router,
    );
  }
}
