// ============================================================================
// BloodNorms | admin_telemetry_service.dart
// Admin Telemetry, AI Voice Configuration, WhatsApp Templates & Call Routing
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';
import 'admin_voice_ai_config_service.dart';
import 'admin_whatsapp_template_service.dart';

export 'admin_voice_ai_config_service.dart';
export 'admin_whatsapp_template_service.dart';

class AdminTelemetryService {
  static final AdminTelemetryService _instance =
      AdminTelemetryService._internal();
  factory AdminTelemetryService() => _instance;
  AdminTelemetryService._internal();

  /// AI Voice Configuration & Training
  Future<Map<String, dynamic>> getAIVoiceConfig() =>
      AdminVoiceAiConfigService().getAIVoiceConfig();

  Future<bool> saveAIVoiceConfig({
    required String prompt,
    required String persona,
    required String language,
    required double temperature,
    required String guidelines,
    required int dailyMinutesCap,
  }) =>
      AdminVoiceAiConfigService().saveAIVoiceConfig(
        prompt: prompt,
        persona: persona,
        language: language,
        temperature: temperature,
        guidelines: guidelines,
        dailyMinutesCap: dailyMinutesCap,
      );

  /// WhatsApp Templates & Triggers
  Future<List<Map<String, dynamic>>> getWhatsAppTemplates() =>
      AdminWhatsAppTemplateService().getWhatsAppTemplates();

  Future<bool> saveWhatsAppTemplates(
          List<Map<String, dynamic>> templates) =>
      AdminWhatsAppTemplateService().saveWhatsAppTemplates(templates);

  /// Telephony Settings
  Future<Map<String, dynamic>> getTelephonySettings() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final row = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'telephony_settings')
            .maybeSingle();
        final val = row?['value'] as Map<String, dynamic>?;
        if (val != null) return val;
      } catch (e) {
        debugPrint('getTelephonySettings error: $e');
      }
    }
    return {
      'provider': 'Twilio / Exotel',
      'caller_id': '+918832471234',
      'max_retries': 3,
      'retry_interval_sec': 60,
      'fallback_to_ivr': true,
      'record_calls': true,
    };
  }

  Future<bool> saveTelephonySettings(Map<String, dynamic> config) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('app_settings').upsert({
          'key': 'telephony_settings',
          'value': config,
          'description':
              'Telephony gateway and voice call routing configuration',
          'updated_at': DateTime.now().toIso8601String(),
        });
        await client.from('audit_logs').insert({
          'action': 'admin_update_telephony_settings',
          'target_type': 'app_settings',
          'target_id': 'telephony_settings',
          'meta': config,
        });
        return true;
      } catch (e) {
        debugPrint('saveTelephonySettings error: $e');
      }
    }
    return false;
  }

  /// Telemetry Metrics (WhatsApp Counts, Voice Calls, Costs)
  Future<Map<String, dynamic>> getTelemetryMetrics() async {
    int totalOutboundMessages = 0;
    int deliveredMessages = 0;
    int readMessages = 0;
    int inboundMessages = 0;

    int totalVoiceCalls = 0;
    int totalVoiceMinutes = 0;
    double estimatedVoiceCost = 0.0;
    List<Map<String, dynamic>> recentCalls = [];
    List<Map<String, dynamic>> recentMessages = [];

    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final msgs = await client
            .from('message_events')
            .select()
            .order('created_at', ascending: false)
            .limit(50);
        recentMessages = List<Map<String, dynamic>>.from(msgs);

        for (final m in recentMessages) {
          final dir = m['direction']?.toString() ?? 'outbound';
          final st = m['status']?.toString() ?? 'sent';
          if (dir == 'inbound') {
            inboundMessages++;
          } else {
            totalOutboundMessages++;
            if (st == 'delivered' || st == 'read') deliveredMessages++;
            if (st == 'read') readMessages++;
          }
        }

        final calls = await client
            .from('voice_calls')
            .select()
            .order('created_at', ascending: false)
            .limit(50);
        recentCalls = List<Map<String, dynamic>>.from(calls);

        for (final c in recentCalls) {
          totalVoiceCalls++;
          final sec = (c['duration_seconds'] as num?)?.toInt() ?? 0;
          totalVoiceMinutes += (sec / 60).ceil();
          final cost = (c['estimated_cost_inr'] as num?)?.toDouble() ?? 0.0;
          estimatedVoiceCost += cost;
        }
      } catch (e) {
        debugPrint('getTelemetryMetrics error: $e');
      }
    }

    return {
      'outbound_messages': totalOutboundMessages,
      'delivered_messages': deliveredMessages,
      'read_messages': readMessages,
      'inbound_messages': inboundMessages,
      'voice_calls_count': totalVoiceCalls,
      'voice_minutes_used': totalVoiceMinutes,
      'estimated_cost_inr': estimatedVoiceCost,
      'recent_calls': recentCalls,
      'recent_messages': recentMessages,
    };
  }

  /// Simulate Voice AI Triage Test
  Map<String, dynamic> simulateAITriageResponse(
    String userSpeech, {
    String prompt = '',
  }) =>
      AdminVoiceAiConfigService().simulateAITriageResponse(
        userSpeech,
        prompt: prompt,
      );
}
