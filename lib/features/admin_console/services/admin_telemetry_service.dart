// ============================================================================
// BloodNorms | admin_telemetry_service.dart
// Admin Telemetry, AI Voice Configuration, WhatsApp Templates & Call Routing
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminTelemetryService {
  static final AdminTelemetryService _instance =
      AdminTelemetryService._internal();
  factory AdminTelemetryService() => _instance;
  AdminTelemetryService._internal();

  /// AI Voice Configuration & Training
  Future<Map<String, dynamic>> getAIVoiceConfig() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final promptRow = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'ai_voice_system_prompt')
            .maybeSingle();

        final capRow = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'ai_voice_daily_minutes_cap')
            .maybeSingle();

        final voiceVal = promptRow?['value'] as Map<String, dynamic>? ?? {};
        final capVal = capRow?['value'];
        int capMinutes = 60;
        if (capVal is Map) {
          capMinutes = (capVal['value'] as num?)?.toInt() ?? 60;
        } else if (capVal is num) {
          capMinutes = capVal.toInt();
        }

        return {
          'prompt': voiceVal['prompt'] ??
              'You are BloodNorms Voice AI Lifesaver Assistant for Rajahmundry. Triage emergency blood requests with calm urgency.',
          'persona': voiceVal['persona'] ?? 'Priya (Clinical Coordinator)',
          'language': voiceVal['language'] ?? 'te-IN / en-IN',
          'temperature':
              (voiceVal['temperature'] as num?)?.toDouble() ?? 0.3,
          'guidelines': voiceVal['guidelines'] ??
              '1. Zero commercial transactions.\n2. Verify hospital location.\n3. Escalate rare groups immediately.',
          'daily_minutes_cap': capMinutes,
        };
      } catch (e) {
        debugPrint('getAIVoiceConfig error: $e');
      }
    }
    return {
      'prompt':
          'You are BloodNorms Voice AI Lifesaver Assistant for Rajahmundry.',
      'persona': 'Priya (Clinical Coordinator)',
      'language': 'te-IN / en-IN',
      'temperature': 0.3,
      'guidelines':
          '1. Zero commercial transactions.\n2. Verify hospital location.\n3. Escalate rare groups.',
      'daily_minutes_cap': 60,
    };
  }

  Future<bool> saveAIVoiceConfig({
    required String prompt,
    required String persona,
    required String language,
    required double temperature,
    required String guidelines,
    required int dailyMinutesCap,
  }) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('app_settings').upsert({
          'key': 'ai_voice_system_prompt',
          'value': {
            'prompt': prompt,
            'persona': persona,
            'language': language,
            'temperature': temperature,
            'guidelines': guidelines,
          },
          'description':
              'AI Voice assistant system prompt and personality configuration',
          'updated_at': DateTime.now().toIso8601String(),
        });

        await client.from('app_settings').upsert({
          'key': 'ai_voice_daily_minutes_cap',
          'value': {'value': dailyMinutesCap},
          'description':
              'Max daily minutes for AI voice before falling back to keypad',
          'updated_at': DateTime.now().toIso8601String(),
        });

        await client.from('audit_logs').insert({
          'action': 'admin_update_ai_voice_config',
          'target_type': 'app_settings',
          'target_id': 'ai_voice_system_prompt',
          'meta': {
            'persona': persona,
            'language': language,
            'temperature': temperature,
            'cap': dailyMinutesCap
          },
        });
        return true;
      } catch (e) {
        debugPrint('saveAIVoiceConfig error: $e');
      }
    }
    return false;
  }

  /// WhatsApp Templates & Triggers
  Future<List<Map<String, dynamic>>> getWhatsAppTemplates() async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        final row = await client
            .from('app_settings')
            .select('value')
            .eq('key', 'whatsapp_templates')
            .maybeSingle();
        final val = row?['value'] as Map<String, dynamic>?;
        if (val != null && val['templates'] is List) {
          return List<Map<String, dynamic>>.from(val['templates']);
        }
      } catch (e) {
        debugPrint('getWhatsAppTemplates error: $e');
      }
    }
    return [
      {
        'id': 'camp_invite',
        'name': 'Blood Camp Invitation',
        'body':
            'Dear {donor_name}, Voluntary Blood Donation Camp is organized at {venue} on {date}. Will you donate? Reply YES to confirm.',
      },
      {
        'id': 'shortage_alert',
        'name': 'Urgent Shortage Alert',
        'body':
            'URGENT: {hospital_name} has critical shortage of {blood_group}. If eligible today, please visit or tap here to accept pass.',
      },
      {
        'id': 'donation_reminder',
        'name': 'Donation Day Reminder',
        'body':
            'Hello {donor_name}, reminder for your scheduled donation today at {bank_name} at {time}. Drink plenty of water!',
      },
      {
        'id': 'appreciation_note',
        'name': 'Donor Thank You',
        'body':
            'Thank you {donor_name}! Your recent donation at {bank_name} saved lives today. You are a true BloodNorms Hero!',
      },
    ];
  }

  Future<bool> saveWhatsAppTemplates(
      List<Map<String, dynamic>> templates) async {
    final client = SupabaseService().client;
    final isInitialized = SupabaseService().isInitialized;

    if (isInitialized && client != null) {
      try {
        await client.from('app_settings').upsert({
          'key': 'whatsapp_templates',
          'value': {'templates': templates},
          'description':
              'WhatsApp Cloud API pre-approved message templates',
          'updated_at': DateTime.now().toIso8601String(),
        });
        await client.from('audit_logs').insert({
          'action': 'admin_update_whatsapp_templates',
          'target_type': 'app_settings',
          'target_id': 'whatsapp_templates',
          'meta': {'count': templates.length},
        });
        return true;
      } catch (e) {
        debugPrint('saveWhatsAppTemplates error: $e');
      }
    }
    return false;
  }

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
  }) {
    final lower = userSpeech.toLowerCase();
    String detectedHospital = 'GGH Rajahmundry';
    if (lower.contains('swatantra')) detectedHospital = 'Swatantra Hospital';
    if (lower.contains('bollineni')) detectedHospital = 'Bollineni Hospital';
    if (lower.contains('rotary') || lower.contains('suraksha')) {
      detectedHospital = 'Suraksha Rotary Blood Bank';
    }

    String detectedGroup = 'O+';
    if (lower.contains('o-') || lower.contains('o negative')) {
      detectedGroup = 'O-';
    } else if (lower.contains('o+') || lower.contains('o positive')) {
      detectedGroup = 'O+';
    } else if (lower.contains('a-') || lower.contains('a negative')) {
      detectedGroup = 'A-';
    } else if (lower.contains('a+') || lower.contains('a positive')) {
      detectedGroup = 'A+';
    } else if (lower.contains('b-') || lower.contains('b negative')) {
      detectedGroup = 'B-';
    } else if (lower.contains('b+') || lower.contains('b positive')) {
      detectedGroup = 'B+';
    } else if (lower.contains('ab-') || lower.contains('ab negative')) {
      detectedGroup = 'AB-';
    } else if (lower.contains('ab+') || lower.contains('ab positive')) {
      detectedGroup = 'AB+';
    }

    final isUrgent = lower.contains('emergency') ||
        lower.contains('critical') ||
        lower.contains('trauma') ||
        lower.contains('urgent') ||
        lower.contains('surgery') ||
        detectedGroup == 'O-';

    String teluguResponse =
        'నమస్కారం, బ్లడ్‌నార్మ్స్ రాజమండ్రి ఎమర్జెన్సీ కంట్రోల్ రూమ్. మేము $detectedHospital లో $detectedGroup రక్తం కోసం అర్జెన్సీ గుర్తించాము. దగ్గరలోని డోనర్లకు మరియు బ్లడ్ బ్యాంకులకు అలర్ట్ పంపుతున్నాము. మీరు నిశ్చింతగా ఉండండి.';
    String englishResponse =
        'Hello, this is BloodNorms Emergency Control. We have verified the requirement for $detectedGroup blood at $detectedHospital. Search Ring 1 has been initiated with highest priority. Please stay on the line.';

    return {
      'detected_hospital': detectedHospital,
      'detected_group': detectedGroup,
      'urgency_tier': isUrgent ? 'TIER 1 CRITICAL' : 'TIER 2 STANDARD',
      'telugu_response': teluguResponse,
      'english_response': englishResponse,
      'simulated_at': DateTime.now().toIso8601String(),
    };
  }
}
