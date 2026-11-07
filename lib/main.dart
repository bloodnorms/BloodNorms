// ============================================================================
// BloodNorms | main.dart
// Entry point for BloodNorms: Duolingo Feather 3D Tactile Theme across Web & Mobile
// ============================================================================

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/i18n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase client
  await SupabaseService().initialize();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      defaultDevice: Devices.ios.iPhone13,
      builder: (context) => const ProviderScope(
        child: BloodNormsApp(),
      ),
    ),
  );
}

class BloodNormsApp extends StatefulWidget {
  const BloodNormsApp({super.key});

  @override
  State<BloodNormsApp> createState() => _BloodNormsAppState();
}

class _BloodNormsAppState extends State<BloodNormsApp> {
  Locale _locale = const Locale('en');

  late final _router = createRouter(
    onLocaleChanged: (newLocale) {
      setState(() => _locale = newLocale);
    },
    onToggleTheme: () {
      // White theme only per user instruction
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Force white theme everywhere
      themeMode: ThemeMode.light,     // Pure white theme only
      locale: DevicePreview.locale(context) ?? _locale,
      builder: DevicePreview.appBuilder,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
