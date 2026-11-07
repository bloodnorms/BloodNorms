// ============================================================================
// BloodNorms | supabase_service.dart
// Supabase client lifecycle facade and domain service orchestrator
// ============================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/admin_console/services/index.dart';
import '../../features/bank_console/services/index.dart';
import '../../features/donor/services/index.dart';
import '../../features/requester/services/index.dart';
import '../constants/app_constants.dart';
import '../models/blood_bank_model.dart';
import '../models/camp_model.dart';
import '../models/donor_badge_model.dart';
import '../models/donor_card_model.dart';
import '../models/notification_model.dart';
import '../models/request_alert_model.dart';
import '../utils/geo_utils.dart' as geo;
import 'notification_service.dart';
import 'realtime_service.dart';

// Model & domain service re-exports for backward compatibility
export '../../features/admin_console/services/index.dart';
export '../../features/bank_console/services/index.dart';
export '../../features/donor/services/index.dart';
export '../../features/requester/services/index.dart';
export '../models/blood_bank_model.dart';
export '../models/camp_model.dart';
export '../models/donor_badge_model.dart';
export '../models/donor_card_model.dart';
export '../models/notification_model.dart';
export '../models/request_alert_model.dart';
export 'notification_service.dart';
export 'realtime_service.dart';
export 'supabase_service_admin_extension.dart';
export 'supabase_service_bank_extension.dart';
export 'supabase_service_donor_extension.dart';
export 'supabase_service_governance_extension.dart';
export 'supabase_service_platform_extension.dart';
export 'supabase_service_realtime_extension.dart';
export 'supabase_service_requester_extension.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize({String? url, String? anonKey}) async {
    final effectiveUrl =
        url ?? dotenv.env['SUPABASE_URL'] ?? AppConstants.defaultSupabaseUrl;
    final effectiveKey = anonKey ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        AppConstants.defaultSupabaseAnonKey;

    if (effectiveUrl.isEmpty || effectiveKey.isEmpty) {
      debugPrint('Supabase notice: Missing URL or Anon key. Running in local fallback mode.');
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: effectiveUrl,
        // ignore: deprecated_member_use
        anonKey: effectiveKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('Supabase successfully initialized with $effectiveUrl');
    } catch (e) {
      debugPrint('Supabase init notice: running in local mock fallback mode ($e)');
      _isInitialized = false;
    }
  }

  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;
  User? get currentUser => client?.auth.currentUser;

  /// Haversine geospatial calculation utility
  double calculateHaversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) =>
      geo.calculateHaversineDistanceKm(lat1, lon1, lat2, lon2);
}
