// ============================================================================
// BloodNorms | main.dart
//
// Entry point for BloodNorms application.
// Initializes bindings, loads environment configuration, initializes Supabase,
// and starts the app with Riverpod and DevicePreview.
// ============================================================================

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'shared/services/supabase_service.dart';

export 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables if available
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    try {
      await dotenv.load(fileName: "assets/.env");
    } catch (_) {}
  }

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
