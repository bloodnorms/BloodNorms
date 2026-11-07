// ============================================================================
// BloodNorms | supabase_service_realtime_extension.dart
// Realtime channel subscriptions extension for SupabaseService
// ============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime_service.dart';
import 'supabase_service.dart';

extension SupabaseServiceRealtimeExtension on SupabaseService {
  RealtimeChannel? subscribeToRequestsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) =>
      RealtimeService().subscribeToRequestsChannel(onData: onData);

  RealtimeChannel? subscribeToStockChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) =>
      RealtimeService().subscribeToStockChannel(onData: onData);

  RealtimeChannel? subscribeToMessageEventsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) =>
      RealtimeService().subscribeToMessageEventsChannel(onData: onData);

  RealtimeChannel? subscribeToCampsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) =>
      RealtimeService().subscribeToCampsChannel(onData: onData);

  RealtimeChannel? subscribeToNotificationsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) =>
      RealtimeService().subscribeToNotificationsChannel(onData: onData);

  void unsubscribeAllChannels() => RealtimeService().unsubscribeAllChannels();
}

