// ============================================================================
// BloodNorms | whatsapp_audit_logger.dart
// Outbound WhatsApp message event logging to Supabase
// ============================================================================

import 'package:flutter/foundation.dart';
import 'messaging_service.dart';
import 'supabase_service.dart';

class WhatsAppAuditLogger {
  /// Log to Supabase message_events and audit_logs
  static Future<void> logOutboundEvent({
    required String toClean,
    required String eventType,
    required bool success,
    required int statusCode,
    String? messageId,
    String? error,
  }) async {
    final maskedPhone = WhatsAppService.maskPhoneForAudit(toClean);
    final payloadMeta = <String, dynamic>{
      'status_code': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (messageId != null) payloadMeta['message_id'] = messageId;
    if (error != null) payloadMeta['error'] = error;

    try {
      final client = SupabaseService().client;
      if (client != null) {
        await client.from('message_events').insert({
          'channel': 'whatsapp',
          'direction': 'outbound',
          'phone_masked': maskedPhone,
          'event_type': eventType,
          'status': success ? 'sent' : 'failed',
          'payload_meta': payloadMeta,
        });
      }
    } catch (e) {
      debugPrint('Failed to log message event to Supabase: $e');
    }
  }
}
