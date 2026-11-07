// ============================================================================
// BloodNorms | app/app.dart
//
// Root application widget for BloodNorms. Configures routing, theming,
// locale support, connectivity banner, and DevicePreview testing wrapper.
// ============================================================================

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../shared/constants/app_constants.dart';
import '../shared/i18n/app_localizations.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/connectivity_banner.dart';
import 'router.dart';

/// Root application widget configuring MaterialApp with GoRouter.
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
      builder: (context, child) => ConnectivityBanner(child: DevicePreview.appBuilder(context, child)),
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

