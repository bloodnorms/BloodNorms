// ============================================================================
// BloodNorms | admin_voice_ai_config_service.dart
// AI Voice Assistant Prompt Configuration, Daily Quotas & Dialogue Simulation
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../shared/services/supabase_service.dart';

class AdminVoiceAiConfigService {
  static final AdminVoiceAiConfigService _instance =
      AdminVoiceAiConfigService._internal();
  factory AdminVoiceAiConfigService() => _instance;
  AdminVoiceAiConfigService._internal();

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
