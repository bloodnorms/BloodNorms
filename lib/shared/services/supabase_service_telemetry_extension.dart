// ============================================================================
// BloodNorms | supabase_service_telemetry_extension.dart
// SupabaseService extension for AI Voice, Telephony, and Telemetry operations
// ============================================================================

import '../../features/admin_console/services/admin_telemetry_service.dart';
import 'supabase_service.dart';

extension SupabaseServiceTelemetryExtension on SupabaseService {
  // Telemetry, AI Voice & Telephony
  Future<Map<String, dynamic>> getAIVoiceConfig() =>
      AdminTelemetryService().getAIVoiceConfig();

  Future<bool> saveAIVoiceConfig({
    required String prompt,
    required String persona,
    required String language,
    required double temperature,
    required String guidelines,
    required int dailyMinutesCap,
  }) =>
      AdminTelemetryService().saveAIVoiceConfig(
        prompt: prompt,
        persona: persona,
        language: language,
        temperature: temperature,
        guidelines: guidelines,
        dailyMinutesCap: dailyMinutesCap,
      );

  Future<List<Map<String, dynamic>>> getWhatsAppTemplates() =>
      AdminTelemetryService().getWhatsAppTemplates();

  Future<bool> saveWhatsAppTemplates(List<Map<String, dynamic>> templates) =>
      AdminTelemetryService().saveWhatsAppTemplates(templates);

  Future<Map<String, dynamic>> getTelephonySettings() =>
      AdminTelemetryService().getTelephonySettings();

  Future<bool> saveTelephonySettings(Map<String, dynamic> config) =>
      AdminTelemetryService().saveTelephonySettings(config);

  Future<Map<String, dynamic>> getTelemetryMetrics() =>
      AdminTelemetryService().getTelemetryMetrics();

  Map<String, dynamic> simulateAITriageResponse(
    String userSpeech, {
    String prompt = '',
  }) =>
      AdminTelemetryService()
          .simulateAITriageResponse(userSpeech, prompt: prompt);
}
