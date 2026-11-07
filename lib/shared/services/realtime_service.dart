// ============================================================================
// BloodNorms | realtime_service.dart
// Centralized Supabase Realtime channel subscriptions and event listener lifecycle
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  RealtimeChannel? _requestsChannel;
  RealtimeChannel? _stockChannel;
  RealtimeChannel? _messageEventsChannel;
  RealtimeChannel? _campsChannel;
  RealtimeChannel? _notificationsChannel;

  SupabaseClient? get _client => SupabaseService().client;

  /// Subscribe to all real-time changes on public.requests
  RealtimeChannel? subscribeToRequestsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final client = _client;
    if (client != null) {
      try {
        _requestsChannel?.unsubscribe();
        _requestsChannel = client
            .channel('public:requests_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'requests',
              callback: onData,
            )
            .subscribe();
        return _requestsChannel;
      } catch (e) {
        debugPrint('subscribeToRequestsChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time changes on public.bank_stock
  RealtimeChannel? subscribeToStockChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final client = _client;
    if (client != null) {
      try {
        _stockChannel?.unsubscribe();
        _stockChannel = client
            .channel('public:stock_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bank_stock',
              callback: onData,
            )
            .subscribe();
        return _stockChannel;
      } catch (e) {
        debugPrint('subscribeToStockChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time message events (WhatsApp / SMS)
  RealtimeChannel? subscribeToMessageEventsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final client = _client;
    if (client != null) {
      try {
        _messageEventsChannel?.unsubscribe();
        _messageEventsChannel = client
            .channel('public:messages_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'message_events',
              callback: onData,
            )
            .subscribe();
        return _messageEventsChannel;
      } catch (e) {
        debugPrint('subscribeToMessageEventsChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time changes on public.bank_camps
  RealtimeChannel? subscribeToCampsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final client = _client;
    if (client != null) {
      try {
        _campsChannel?.unsubscribe();
        _campsChannel = client
            .channel('public:camps_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'bank_camps',
              callback: onData,
            )
            .subscribe();
        return _campsChannel;
      } catch (e) {
        debugPrint('subscribeToCampsChannel error: $e');
      }
    }
    return null;
  }

  /// Subscribe to all real-time changes on public.notifications
  RealtimeChannel? subscribeToNotificationsChannel({
    required void Function(PostgresChangePayload payload) onData,
  }) {
    final client = _client;
    if (client != null) {
      try {
        _notificationsChannel?.unsubscribe();
        _notificationsChannel = client
            .channel('public:notifications_realtime')
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'notifications',
              callback: onData,
            )
            .subscribe();
        return _notificationsChannel;
      } catch (e) {
        debugPrint('subscribeToNotificationsChannel error: $e');
      }
    }
    return null;
  }

  /// Tear down and unsubscribe from all active channels
  void unsubscribeAllChannels() {
    try {
      _requestsChannel?.unsubscribe();
      _stockChannel?.unsubscribe();
      _messageEventsChannel?.unsubscribe();
      _campsChannel?.unsubscribe();
      _notificationsChannel?.unsubscribe();
    } catch (e) {
      debugPrint('unsubscribeAllChannels error: $e');
    }
  }
}
